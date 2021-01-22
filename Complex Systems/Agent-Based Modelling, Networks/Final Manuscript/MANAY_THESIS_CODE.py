# Import necessary packages
import networkx as nx
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1 import make_axes_locatable
import numpy as np
import scipy.stats as stats
import seaborn as sns
import glob
import os
import geopandas as gpd
import copy

# Suppress scientific notation for pandas
pd.options.display.float_format = '{:.10f}'.format

# Set parameters for all matplotlib/seaborn plots
mpl.rcParams["text.usetex"] = True
mpl.rcParams['figure.dpi']= 150

##### 1. DATA CLEANING AND PRE-PROCESSING
# Read all files in folder
files = glob.glob(os.path.join("IC data", "*.csv"))
trade_df = pd.concat((pd.read_csv(file, index_col = None, header = 0) for file in files), axis = 0, ignore_index = True)

# Read CPI_US file
cpi_df = pd.read_csv("Other Data/US_CPI.csv", index_col = None, header = 0)

# Drop columns
trade_df = trade_df[["yr", "rt3ISO", "pt3ISO", "rgDesc", "TradeValue"]]

# Change column names
trade_df.columns = ["year", "reporter", "partner", "indicator", "weight"]

# Remove rows with nans
trade_df.dropna(inplace = True)

# Change year to ints
trade_df["year"] = trade_df["year"].apply(lambda x: int(x))

# Separate imports from exports 
trade_exports = trade_df[trade_df["indicator"] == "Export"].reset_index(drop = True)
trade_imports = trade_df[trade_df["indicator"] == "Import"].reset_index(drop = True)

# Merge import and export dataframes
trade_df = trade_exports.merge(trade_imports, left_on = ["year", "reporter", "partner"], right_on = ["year", "partner", "reporter"], suffixes = ("_exp", "_imp"))

# Drop unnecessary columns
trade_df.drop(["reporter_imp", "partner_imp", "indicator_exp", "indicator_imp"], axis = 1, inplace = True)

# Change name of other columns
trade_df.rename(columns = {"reporter_exp": "source", "partner_exp": "target"}, inplace = True)

# Average weight_exp and weight_imp
trade_df["weight"] = (trade_df["weight_exp"] + trade_df["weight_imp"]) / 2

# Drop weight columns
trade_df.drop(["weight_exp", "weight_imp"], axis = 1, inplace = True)

# Express CPI where with 2013 as base year (i.e., divide all values by the 2013 CPI) to get deflation factor
base = cpi_df.loc[cpi_df["year"] == 2013, "CPI"]
cpi_df["CPI"] = cpi_df["CPI"].apply(lambda x: x / base)

# Multiply trade figures by deflation factor based on year
trade_df = trade_df.merge(cpi_df, on = "year")
trade_df["weight"] = trade_df["weight"] * trade_df["CPI"]

# Drop CPI column
trade_df.drop(["CPI"], axis = 1, inplace = True)

# Merge trade with itself 
trade_new = trade_df.merge(trade_df, left_on = ["year", "source", "target"], right_on = ["year", "target", "source"], suffixes = ("_1", "_2"))

# Get net trade flow
trade_new["weight"] = trade_new["weight_1"] - trade_new["weight_2"]

# Delete all rows where weight is negative. Reset row indices
trade_new = trade_new[trade_new["weight"] > 0]
trade_new = trade_new.reset_index(drop = True)

# Drop extraneous columns and rename other columns
trade_new.drop(["weight_1", "source_2", "target_2", "weight_2"], axis = 1, inplace = True)
trade_new.rename(columns = {"source_1": "source", "target_1": "target"}, inplace = True)
trade_df = trade_new

##### 2. GRAPHING THE NETWORK
# Make a list of all years
years = sorted(list(set(trade_df["year"])))

# Initialize dictionaries
all_links = {}
all_countries = {}

for year in years:
    
    # Get subset of trade dataframe based on yeark
    trade_sub = trade_df[trade_df["year"] == year]
    
    # Get set of all sources, targets and links
    sources = set(trade_sub["source"])
    targets = set(trade_sub["target"])
    links = trade_sub[["source", "target", "weight"]].values.tolist()
    
    # Take the union of the set of source countries and the set of target countries to form set of nodes
    countries = list(sources.union(targets))
    
    # Assign links and countries to dictionary
    all_links[year] = links
    all_countries[year] = countries
    
# Create mapping from year to graph
all_graphs = {}

for year in years:
    all_graphs[year] = nx.DiGraph()
        
# Create nodes
for year in years:
    all_graphs[year].add_nodes_from(all_countries[year])
    
# Create edges
for year in years:
    all_graphs[year].add_weighted_edges_from(all_links[year])
    
for year in years:
    # Initialize graph. Use force-directed layout
    fig, ax = plt.subplots(figsize = (15, 15))
    pos = nx.layout.spring_layout(all_graphs[year], k = 1600, iterations = 50)
       
    # Draw nodes, edges and labels
    nodes = nx.draw_networkx_nodes(all_graphs[year], pos, nodelist = all_graphs[year].nodes(), nodesize = 1000)
    edges = nx.draw_networkx_edges(all_graphs[year], pos, edgelist = all_graphs[year].edges(), arrowstyle = '->', arrowsize = 10, width = 1)
    nx.draw_networkx_labels(all_graphs[year], pos, font_size = 10, ax = ax)
    
    # Configure graph
    ax.set_title(str(year) + " Integrated Circuit Trade Network", fontdict = {'fontsize': 15})
    ax.set_axis_off()

# Load shapefile
gdf = gpd.read_file("Other Data/ne_10m_admin_0_countries_lakes.shp")[["ADM0_A3", "geometry"]].to_crs({"init" : "epsg:4326"})

##### 3. NETWORK CHARACTERIZATION
##### 3.1 Network Density

##### Compute network density
# Create list of network density per year.
density_list = [nx.density(all_graphs[year]) for year in years]

##### Plot network density
# Plot graph
fig, ax = plt.subplots()
sns.set(style = "dark")
ax.plot(years, density_list)
ax.set_title("Link Density for the Integrated Circuit Trade Network")
ax.set_xlabel("Year")
ax.set_ylabel("Network Density")
ax.locator_params(integer = True)

###### 3.2 Total Link Weight
##### Compute total link weight
# Create list of total link weight per year.
tot_weight_list = [all_graphs[year].size(weight = "weight") for year in years]

##### Plot total link weight
# Plot graph
fig, ax = plt.subplots()
sns.set(style = "dark")
ax.plot(years, tot_weight_list)
ax.set_title("Total Link Weight for the Integrated Circuit Trade Network ($\\times 10^{11}$)")
ax.set_xlabel("Year")
ax.set_ylabel("Total Link Weight")
ax.locator_params(integer = True)
ax.yaxis.get_offset_text().set_visible(False)

###### 3.3 Degree Assortativity
##### Compute network assortativity
# Create list of network assortativity per year
assortativity_list = []
for year in years:
    graphs = all_graphs[year]
    assortativity_list.append(nx.degree_assortativity_coefficient(graphs))
    
##### Plot network assortativity
# Plot graph
fig, ax = plt.subplots()
sns.set(style = "dark")
ax.plot(years, assortativity_list)
ax.set_title("Degree Assortativity for the Integrated Circuit Trade Network")
ax.set_xlabel("Year")
ax.set_ylabel("Network Assortativity")
ax.locator_params(integer = True)

###### 3.4 Degree Centrality
##### Compute in-degree and out-degree
# Create in-degree and out-degree dictionaries for each year
all_in_degrees = {}
all_out_degrees = {}

for year in years:
    all_in_degrees[year] = dict(all_graphs[year].in_degree)
    all_out_degrees[year] = dict(all_graphs[year].out_degree)
    
##### Plot degree map
for year in years:
    # Convert dictionaries to dataframes
    in_degree_df = pd.DataFrame.from_dict(all_in_degrees[year], orient = "index")
    in_degree_df.rename(columns = {0: "in-degree"}, inplace = True)

    out_degree_df = pd.DataFrame.from_dict(all_out_degrees[year], orient = "index")
    out_degree_df.rename(columns = {0: "out-degree"}, inplace = True)
    
    # Reset index
    in_degree_df.reset_index(inplace = True)
    in_degree_df.rename(columns = {"index": "Country Code"}, inplace = True)

    out_degree_df.reset_index(inplace = True)
    out_degree_df.rename(columns = {"index": "Country Code"}, inplace = True)

    # Merge
    degree_df = in_degree_df.merge(out_degree_df, left_on = "Country Code", right_on = "Country Code")

    # Merge with geodataframe
    degree_map = gdf.merge(degree_df, how = "left", left_on = "ADM0_A3", right_on = "Country Code")

    # Plot gray map
    fig, (ax_in, ax_out) = plt.subplots(1, 2, figsize = (16, 20))
    degree_map.plot(color = "gray", ax = ax_in)
    degree_map.plot(color = "gray", ax = ax_out)
    
    # Remove rows for which in-degree = 0 or out-degree = 0
    degree_map = degree_map[(degree_map["in-degree"] != 0) & (degree_map["out-degree"] != 0)]
    
    # Legend axis
    divider_in = make_axes_locatable(ax_in)
    cax_in = divider_in.append_axes("right", size = "5%", pad = 0.1)
    divider_out = make_axes_locatable(ax_out)
    cax_out = divider_out.append_axes("right", size = "5%", pad = 0.1)
    
    # Plot choropleth layer
    degree_map.dropna().plot(column = "in-degree", cmap = "Blues", ax = ax_in, legend = True, cax = cax_in)
    ax_in.set_title("In-Degree Map for " + str(year))
    ax_in.set_axis_off()
    
    degree_map.dropna().plot(column = "out-degree", cmap = "Reds", ax = ax_out, legend = True, cax = cax_out)
    ax_out.set_title("Out-Degree Map for " + str(year))
    ax_out.set_axis_off()
    
    fig.tight_layout()
    
##### Plot degree rank-size distribution
# Plot distribution of in-degrees and out-degrees
fig, (ax1, ax2) = plt.subplots(1, 2, figsize = (10, 3))

# Construct list of y-values. Remove 0's in the list
y_list = sorted(all_in_degrees[2017].values(), reverse = True)
y_list = np.array([i for i in y_list if i != 0])

# Construct list of x-values
x_list = stats.rankdata(np.negative(y_list), method = "dense")

ax1.scatter(x_list, y_list)
ax1.set_title("In-Degree Distribution, 2017")
ax1.set_xlabel("Rank - descending order")
ax1.set_ylabel("In-degree")

# Construct list of y-values. Remove 0's in the list
y_list = sorted(all_out_degrees[2017].values(), reverse = True)
y_list = np.array([i for i in y_list if i != 0])

# Construct list of x-values
x_list = stats.rankdata(np.negative(y_list), method = "dense")

ax2.scatter(x_list, y_list)
ax2.set_title("Out-Degree Distribution, 2017")
ax2.set_xlabel("Rank - descending order")
ax2.set_ylabel("Out-degree")

fig.tight_layout()

# Get top 10 countries
degree_df.sort_values(by = ["in-degree"], ascending = False).head(10)
degree_df.sort_values(by = ["out-degree"], ascending = False).head(10)

##### 3.5 Strength Centrality
##### Compute in-strength and out-strength
# Create in-strength and out-strength dictionary
all_in_strengths = {}
all_out_strengths = {}
average_trade = {}

for year in years:
    all_in_strengths[year] = {}
    all_out_strengths[year] = {}
    average_trade[year] = {}
    
    for country in all_countries[year]:
        all_in_strengths[year][country] = 0
        all_out_strengths[year][country] = 0
        average_trade[year][country] = 0

for year in years:
    links = all_links[year]
    countries = all_countries[year]
    weight_total = 0
    
    # Fill in values
    for link in links:
        source = link[0]
        target = link[1]
        weight = link[2]
        
        all_in_strengths[year][target] += float(weight)
        all_out_strengths[year][source] += float(weight)
        weight_total += float(weight)
    
    average_trade[year] = weight_total / len(countries)
    
    # Normalize
    for country in countries:
        all_in_strengths[year][country] /= weight_total
        all_out_strengths[year][country] /= weight_total

##### Plot strength map
for year in years:
    in_strength_df = pd.DataFrame.from_dict(all_in_strengths[year], orient = "index")
    in_strength_df.rename(columns = {0: "in-strength"}, inplace = True)

    out_strength_df = pd.DataFrame.from_dict(all_out_strengths[year], orient = "index")
    out_strength_df.rename(columns = {0: "out-strength"}, inplace = True)
    
    # Reset index
    in_strength_df.reset_index(inplace = True)
    in_strength_df.rename(columns = {"index": "Country Code"}, inplace = True)

    out_strength_df.reset_index(inplace = True)
    out_strength_df.rename(columns = {"index": "Country Code"}, inplace = True)
    
    # Merge
    strength_df = in_strength_df.merge(out_strength_df, left_on = "Country Code", right_on = "Country Code")
    
    # Merge with geodataframe
    strength_map = gdf.merge(strength_df, how = "left", left_on = "ADM0_A3", right_on = "Country Code")
    
    # Plot gray map
    fig, (ax_in, ax_out) = plt.subplots(1, 2, figsize = (16, 20))
    strength_map.plot(color = "gray", figsize = (15, 20), ax = ax_in)
    strength_map.plot(color = "gray", figsize = (15, 20), ax = ax_out)
    
    # Remove rows for which in-strength = 0 or out-strength = 0
    strength_map = strength_map[(strength_map["in-strength"] != 0) & (strength_map["out-strength"] != 0)]
    
    # Legend axis
    divider_in = make_axes_locatable(ax_in)
    cax_in = divider_in.append_axes("right", size = "5%", pad = 0.1)
    divider_out = make_axes_locatable(ax_out)
    cax_out = divider_out.append_axes("right", size = "5%", pad = 0.1)
    
    # Plot choropleth layer
    strength_map.dropna().plot(column = "in-strength", cmap = "Blues", legend = True, ax = ax_in, cax = cax_in)
    ax_in.set_title("In-Strength Centrality Map for " + str(year), fontdict = {'fontsize': 20})
    ax_in.set_axis_off()
    
    strength_map.dropna().plot(column = "out-strength", cmap = "Reds", legend = True, ax = ax_out, cax = cax_out)
    ax_out.set_title("Out-Strength Map Centrality for " + str(year), fontdict = {'fontsize': 20})
    ax_out.set_axis_off()
    
    fig.tight_layout()

##### Plot strength rank-size distribution
# Plot distribution of in-strength and out-strength centrality
fig, ax = plt.subplots(2, 2, figsize = (10, 6))

# Construct list of y-values. Remove 0's in the list
y_list = sorted(all_in_strengths[2017].values(), reverse = True)
y_list = np.array([i for i in y_list if i != 0])

# Construct list of x-values
x_list = stats.rankdata(np.negative(y_list), method = "dense")

ax[0, 0].scatter(x_list, y_list)
ax[0, 0].set_title("In-Strength Centrality Distribution, 2017")
ax[0, 0].set_xlabel("Rank - descending order")
ax[0, 0].set_ylabel("In-strength centrality")

ax[0, 1].scatter(x_list, np.log(y_list))
ax[0, 1].set_title("In-Strength Centrality Distribution, 2017")
ax[0, 1].set_xlabel("Rank - descending order")
ax[0, 1].set_ylabel("Log of in-strength centrality")

# Construct list of y-values. Remove 0's in the list
y_list = sorted(all_out_strengths[2017].values(), reverse = True)
y_list = np.array([i for i in y_list if i != 0])

# Construct list of x-values
x_list = stats.rankdata(np.negative(y_list), method = "dense")

ax[1, 0].scatter(x_list, y_list)
ax[1, 0].set_title("Out-Strength Centrality Distribution, 2017")
ax[1, 0].set_xlabel("Rank - descending order")
ax[1, 0].set_ylabel("Out-strength centrality")

ax[1, 1].scatter(x_list, np.log(y_list))
ax[1, 1].set_title("Out-Strength Centrality Distribution, 2017")
ax[1, 1].set_xlabel("Rank - descending order")
ax[1, 1].set_ylabel("Log of out-strength centrality")

fig.tight_layout()

# Get top 10 countries
strength_df.sort_values(by = ["in-strength"], ascending = False).head(10)
strength_df.sort_values(by = ["out-strength"], ascending = False).head(10)

##### 3.5 Betweenness Centrality
##### Compute betweenness centrality
# Create copy of original trade network links
all_links_inv = copy.deepcopy(all_links)

# Modify weights
for year in years:
    links = all_links_inv[year]
    
    for link in links:
        if link[2] != 0:
            link[2] = average_trade[year] / float(link[2])
            
# Create mapping from year to graph
all_graphs_inv = {}

for year in years:
    all_graphs_inv[year] = nx.DiGraph()

# Create nodes
for year in years:
    all_graphs_inv[year].add_nodes_from(all_countries[year])

# Create edges
for year in years:
    all_graphs_inv[year].add_weighted_edges_from(all_links_inv[year])
    
# Create betweenness centrality dictionary for each year
all_betweenness = {}

for year in years:
    graphs = all_graphs_inv[year]
    
    all_betweenness[year] = dict(nx.betweenness_centrality(graphs, weight = "weight"))

##### Plot betweenness map    
for year in years:
    # Convert dictionaries to dataframes
    betweenness_df = pd.DataFrame.from_dict(all_betweenness[year], orient = "index")
    betweenness_df.rename(columns = {0: "betweenness"}, inplace = True)
    
    # Reset index
    betweenness_df.reset_index(inplace = True)
    betweenness_df.rename(columns = {"index": "Country Code"}, inplace = True)
    
    # Merge with geodataframe
    betweenness_map = gdf.merge(betweenness_df, how = "left", left_on = "ADM0_A3", right_on = "Country Code")
    
    # Plot gray map
    ax = betweenness_map.plot(color = "gray", figsize = (16, 20))
    
    # Remove rows for which betweenness = 0
    betweenness_map = betweenness_map[betweenness_map["betweenness"] != 0]
    
    # Legend axis
    divider = make_axes_locatable(ax)
    cax = divider.append_axes("right", size = "5%", pad = 0.1)
    
    # Plot choropleth layer
    betweenness_map.dropna().plot(column = "betweenness", cmap = "Blues", legend = True, ax = ax, cax = cax)
    ax.set_title("Betweenness Centrality Map for " + str(year), fontdict = {'fontsize': 20})
    ax.set_axis_off()

##### Plot betweenness rank-size distribution 
# Plot distribution of betweenness centrality
fig, (ax1, ax2) = plt.subplots(1, 2, figsize = (10, 3))

# Construct list of y-values. Remove 0's in the list
y_list = sorted(all_betweenness[2017].values(), reverse = True)
y_list = np.array([i for i in y_list if i != 0])

# Construct list of x-values
x_list = stats.rankdata(np.negative(y_list), method = "dense")

ax1.scatter(x_list, y_list)
ax1.set_title("Betweenness Centrality Distribution, 2017")
ax1.set_xlabel("Rank - descending order")
ax1.set_ylabel("Betweenness centrality")

# Construct list of y-values. Remove 0's in the list
y_list = sorted(all_betweenness[2017].values(), reverse = True)
y_list = np.array([i for i in y_list if i != 0])

# Construct list of x-values
x_list = stats.rankdata(np.negative(y_list), method = "dense")

ax2.scatter(x_list, np.log(y_list))
ax2.set_title("Betweenness Centrality Distribution, 2017")
ax2.set_xlabel("Rank - descending order")
ax2.set_ylabel("Log of betweenness centrality")

# Get top 10 countries
betweenness_df.sort_values(by = ["betweenness"], ascending = False).head(10)

##### 3.6 Eigenvector Centrality
##### Compute in-eigenvector and out-eigenvector
# Create eigenvector centrality dictionary for each year
all_in_eigenvector = {}
all_out_eigenvector = {}

for year in years:
    graphs = all_graphs[year]
    reverse_graphs = all_graphs[year].reverse()
    
    all_in_eigenvector[year] = dict(nx.eigenvector_centrality_numpy(graphs, weight = "weight"))
    all_out_eigenvector[year] = dict(nx.eigenvector_centrality_numpy(reverse_graphs, weight = "weight"))

##### Plot eigenvector map
for year in years:
    # Convert dictionaries to dataframes
    in_eigenvector_df = pd.DataFrame.from_dict(all_in_eigenvector[year], orient = "index")
    in_eigenvector_df.rename(columns = {0: "in-eigenvector"}, inplace = True)
    in_eigenvector_df[in_eigenvector_df["in-eigenvector"] < 0] = 0

    out_eigenvector_df = pd.DataFrame.from_dict(all_out_eigenvector[year], orient = "index")
    out_eigenvector_df.rename(columns = {0: "out-eigenvector"}, inplace = True)
    out_eigenvector_df[out_eigenvector_df["out-eigenvector"] < 0] = 0

    # Reset index
    in_eigenvector_df.reset_index(inplace = True)
    in_eigenvector_df.rename(columns = {"index": "Country Code"}, inplace = True)
    
    out_eigenvector_df.reset_index(inplace = True)
    out_eigenvector_df.rename(columns = {"index": "Country Code"}, inplace = True)
    
    # Merge
    eigenvector_df = in_eigenvector_df.merge(out_eigenvector_df, left_on = "Country Code", right_on = "Country Code")

    # Merge with geodataframe
    eigenvector_map = gdf.merge(eigenvector_df, how = "left", left_on = "ADM0_A3", right_on = "Country Code")
    
    # Plot gray map
    fig, (ax_in, ax_out) = plt.subplots(1, 2, figsize = (16, 20))
    eigenvector_map.plot(color = "gray", ax = ax_in)
    eigenvector_map.plot(color = "gray", ax = ax_out)
    
    # Legend axis
    divider_in = make_axes_locatable(ax_in)
    cax_in = divider_in.append_axes("right", size = "5%", pad = 0.1)
    divider_out = make_axes_locatable(ax_out)
    cax_out = divider_out.append_axes("right", size = "5%", pad = 0.1)
    
    # Plot choropleth layer
    eigenvector_map.dropna().plot(column = "in-eigenvector", cmap = "Blues", legend = True, ax = ax_in, cax = cax_in)
    ax_in.set_title("In-Eigenvector Centrality Map for " + str(year), fontdict = {'fontsize': 20})
    ax_in.set_axis_off()

    eigenvector_map.dropna().plot(column = "out-eigenvector", cmap = "Reds", legend = True, ax = ax_out, cax = cax_out)
    ax_out.set_title("Out-Eigenvector Centrality Map for " + str(year), fontdict = {'fontsize': 20})
    ax_out.set_axis_off()

##### Plot eigenvector rank-size distribution
# Plot distribution of in-eigenvector and out-eigenvector centrality
fig, ax = plt.subplots(2, 2, figsize = (10, 6))

# Construct list of y-values. Remove 0's in the list
y_list = sorted(all_in_eigenvector[2017].values(), reverse = True)
y_list = np.array([i for i in y_list if i != 0])

# Construct list of x-values
x_list = stats.rankdata(np.negative(y_list), method = "dense")

ax[0, 0].scatter(x_list, y_list)
ax[0, 0].set_title("In-Eigenvector Centrality Distribution, 2017")
ax[0, 0].set_xlabel("Rank - descending order")
ax[0, 0].set_ylabel("In-Eigenvector centrality")

ax[0, 1].scatter(x_list, np.log(y_list))
ax[0, 1].set_title("In-Eigenvector Centrality Distribution, 2017")
ax[0, 1].set_xlabel("Rank - descending order")
ax[0, 1].set_ylabel("Log of In-Eigenvector centrality")

# Construct list of y-values. Remove 0's in the list
y_list = sorted(all_out_eigenvector[2017].values(), reverse = True)
y_list = np.array([i for i in y_list if i != 0])

# Construct list of x-values
x_list = stats.rankdata(np.negative(y_list), method = "dense")

ax[1, 0].scatter(x_list, y_list)
ax[1, 0].set_title("Out-Eigenvector Centrality Distribution, 2017")
ax[1, 0].set_xlabel("Rank - descending order")
ax[1, 0].set_ylabel("Out-Eigenvector centrality")

ax[1, 1].scatter(x_list, np.log(y_list))
ax[1, 1].set_title("Out-Eigenvector Centrality Distribution, 2017")
ax[1, 1].set_xlabel("Rank - descending order")
ax[1, 1].set_ylabel("Log of Out-Eigenvector centrality")

fig.tight_layout()

# Get top 10 countries
eigenvector_df.sort_values(by = ["in-eigenvector"], ascending = False).head(10)
eigenvector_df.sort_values(by = ["out-eigenvector"], ascending = False).head(10)

##### 4. SHOCK PROPAGATION (SUPPLY-SIDE DECREASE)
##### Code shock propagation function
# Get neighbors with respect to out-edges of all nodes
def neighbor_out(graph):
    neighbor_dict = {}

    for node in list(graph.nodes):
        neighbor_list = []
        for source, target in list(graph.out_edges(node)):
            neighbor_list.append(target)
        neighbor_dict[node] = neighbor_list
    
    return neighbor_dict

# Implement shock propagation simulation
def sim_cascade_1(graph, start_node, k, shock_param, spread_param, kmax = 50):
    # Initialize matrices
    countries = list(graph.nodes)
    nc = len(countries)
    neighbors = neighbor_out(graph)
    
    trade = np.zeros((kmax + 1, nc, nc), dtype = 'float64')
    exports = np.zeros((kmax + 1, nc), dtype = 'float64')
    transfer = np.zeros((nc, nc), dtype = 'float64')
    shocks_prev = np.zeros(nc, dtype = 'float64')
    
    # Initialize trade matrix
    adj = np.asarray(nx.adjacency_matrix(graph).todense())
    trade[0, :, :] = adj.copy()
    exports[0, :] = np.sum(trade[0, :, :], axis = 1)
        
    # Initialize transfer matrix and then normalize
    transfer = trade[0, :, :]
    row_sums = np.sum(transfer, axis = 1)
    transfer = np.divide(transfer, row_sums.reshape(-1, 1), where = row_sums.reshape(-1, 1) != 0)
    transfer = np.nan_to_num(transfer)
    
    # Initialize variables for the metrics
    cascade_depth = 0
    cascade_nodes = []
    exposure_arr = np.zeros(nc, dtype = 'float64')
    
    # Main loop
    for step in range(1, k + 1):
        # Initialize matrices
        temp_exports = np.zeros(nc, dtype = 'float64')
        delta_exports = np.zeros(nc, dtype = 'float64')
        delta_trade = np.zeros((nc, nc), dtype = 'float64')
        shocked = np.zeros((nc, nc), dtype = 'float64')
        shocks = np.zeros(nc, dtype = 'float64')
        
        # Initial shock
        if step == 1:
            # Initialize shock matrix
            for neighbor in neighbors[start_node]:
                shocked[countries.index(start_node), countries.index(neighbor)] = 1
            
            # Get all "children" of the start_node (i.e., all neighbors wrt outgoing edges)
            children = neighbors[start_node]
            
            # Initial shock: decrease exports of start_node by shock_param
            shocks[countries.index(start_node)] = shock_param * exports[0, countries.index(start_node)]
        
        # Subsequent shocks
        else:
            # Initialize children_placeholder
            children_placeholder = []
            
            # Run through all the children's neighbors. Store the neighbors of these neighbors in children_placeholder
            for child in children:
                for neighbor in neighbors[child]:
                    shocked[countries.index(child), countries.index(neighbor)] = 1
                    children_placeholder.append(neighbor)
            
            # Replace children with children_placeholder
            children = list(set(children_placeholder))
            
            # Subsequent shocks: decrease exports of affected nodes by spread_param
            shocks = shocks_prev * spread_param
        
        # Allocate shock to trade partners
        delta_trade = transfer * shocked * shocks.reshape(-1, 1)
        delta_exports = np.sum(delta_trade, axis = 1)
        
        # Store all shocks received by each country in this iteration for reference in next iteration
        shocks_prev = np.sum(delta_trade, axis = 0)
        
        # Store new exports in temp_exports.
        temp_exports = exports[step - 1, :] - delta_exports
        
        if np.any(temp_exports < 0):
            # Get exposure for all countries. 
            shock_init = shock_param * exports[0, countries.index(start_node)]
                
            if shock_init > 0:
                exposure_arr = (exports[1, :] - temp_exports) / shock_init
            else:
                exposure_arr = exports[1, :] - temp_exports # list of zeroes
        
            # Zero out exposure for start_node
            #exposure_arr[countries.index(start_node)] = 0
                
            # Stop if there are negative exports.
            break
            
        else:
            # Update trade and export matrices
            exports[step, :] = exports[step - 1, :] - delta_exports
            trade[step, :, :] = trade[step - 1, :] - delta_trade
        
            # Update transfer matrix
            transfer = trade[step, :, :]
            row_sums = np.sum(transfer, axis = 1)
            transfer = np.divide(transfer, row_sums.reshape(-1, 1), where = row_sums.reshape(-1, 1) != 0)
            transfer = np.nan_to_num(transfer)
            
            # Update cascade depth
            cascade_depth += 1
            
            # Update cascade_nodes
            cascade_nodes.extend(children)
    
    return {"exports": exports, "cascade depth": cascade_depth, "cascade size": len(set(cascade_nodes)), "exposure": exposure_arr}

##### Run shock propagation simulation on all countries
def run_sim_cascade_1(graph, start_node, k):
    # Initialize variables
    countries = list(graph.nodes)
    nc = len(countries)
    iter_count = 0
    res_total = {"cascade depth": 0, "cascade size": 0, "exposure": np.zeros(nc, dtype = 'float64')}
    
    # Run for all possible values in parameter space
    for shock in np.arange(0, 1, 0.1):
        for spread in np.arange(0, 1, 0.1):
            iter_count += 1
            res = sim_cascade_1(graph, start_node, k, shock, spread)
            res_total["cascade depth"] += res["cascade depth"]
            res_total["cascade size"] += res["cascade size"]
            res_total["exposure"] += res["exposure"]
    
    # Average all metrics
    res_ave = {key: val / iter_count for key, val in res_total.items()}
    
    return res_ave

# Find cascade size, depth and exposure for all countries
graphs = all_graphs[2017] 
countries = list(graphs.nodes)
nc = len(countries)
all_cascade_sizes = {}
all_cascade_depths = {}
exposure_mat = np.zeros((nc, nc), dtype = 'float64')

# Map cascade sizes and depths to countries
for country in countries:
    res = run_sim_cascade_1(graph = graphs, start_node = country, k = 50)
    all_cascade_sizes[country] = res["cascade size"]
    all_cascade_depths[country] = res["cascade depth"]
    exposure_mat[countries.index(country), :] = res["exposure"]
    
# Convert dictionaries (and matrix) to dataframes
cascade_size_df = pd.DataFrame.from_dict(all_cascade_sizes, orient = "index")
cascade_size_df.rename(columns = {0: "cascade size"}, inplace = True)

cascade_depth_df = pd.DataFrame.from_dict(all_cascade_depths, orient = "index")
cascade_depth_df.rename(columns = {0: "cascade depth"}, inplace = True)

exposure_df = pd.DataFrame(data = exposure_mat.astype(np.float))
exposure_df.set_axis(countries, axis = 0, inplace = True)
exposure_df.set_axis(countries, axis = 1, inplace = True)

# Reset index
cascade_size_df.reset_index(inplace = True)
cascade_size_df.rename(columns = {"index": "Country Code"}, inplace = True)

cascade_depth_df.reset_index(inplace = True)
cascade_depth_df.rename(columns = {"index": "Country Code"}, inplace = True)

# Create outgoing directory
output_dir = "./Simulation Results"
if not os.path.exists(output_dir):
    os.mkdir(output_dir)

# Write to csv files
cascade_size_df.to_csv(os.path.join(output_dir, "sim1_cascade_size.csv"), index = False)
cascade_depth_df.to_csv(os.path.join(output_dir, "sim1_cascade_depth.csv"), index = False)
exposure_df.to_csv(os.path.join(output_dir, "sim1_exposure.csv"))

##### 4.1 Geographic Distribution of Cascade Size & Depth
##### Plot cascade size and depth map
# Read cascade_size and cascade_depth dataframes
cascade_size_df = pd.read_csv("Simulation Results/sim1_cascade_size.csv", index_col = None, header = 0)
cascade_depth_df = pd.read_csv("Simulation Results/sim1_cascade_depth.csv", index_col = None, header = 0)

# Merge
cascade_df = cascade_size_df.merge(cascade_depth_df, left_on = "Country Code", right_on = "Country Code")

# Merge with geodataframe
cascade_map = gdf.merge(cascade_df, how = "left", left_on = "ADM0_A3", right_on = "Country Code")
    
# Plot gray map
fig, (ax_size, ax_depth) = plt.subplots(1, 2, figsize = (16, 20))
cascade_map.plot(color = "gray", ax = ax_size)
cascade_map.plot(color = "gray", ax = ax_depth)

# Remove countries for which cascade size = 0 or cascade depth = 0.
cascade_map = cascade_map[(cascade_map["cascade size"] != 0) & (cascade_map["cascade depth"] != 0)]

# Legend axis
divider_size = make_axes_locatable(ax_size)
cax_size = divider_size.append_axes("right", size = "5%", pad = 0.1)
divider_depth = make_axes_locatable(ax_depth)
cax_depth = divider_depth.append_axes("right", size = "5%", pad = 0.1)    

# Plot choropleth layer
cascade_map.dropna().plot(column = "cascade size", cmap = "Blues", legend = True, ax = ax_size, cax = cax_size)
ax_size.set_title("Cascade Size Map for " + str(year), fontdict = {'fontsize': 20})
ax_size.set_axis_off()
    
cascade_map.dropna().plot(column = "cascade depth", cmap = "Blues", legend = True, ax = ax_depth, cax = cax_depth)
ax_depth.set_title("Cascade Depth Map for " + str(year), fontdict = {'fontsize': 20})
ax_depth.set_axis_off()

##### 4.2 Distribution based on Shock and Spread Parameters
##### Plot rank-size distribution for average cascade size and depth
# Plot distribution of cascade size and depth
fig, (ax1, ax2) = plt.subplots(1, 2, figsize = (10, 3))

# Construct list of y-values. Remove 0's in the list
y_list = sorted(cascade_size_df["cascade size"], reverse = True)
y_list = np.array([i for i in y_list if i != 0])

# Construct list of x-values
x_list = stats.rankdata(np.negative(y_list), method = "dense")

ax1.scatter(x_list, y_list)
ax1.set_title("Cascade Size Distribution, 2017")
ax1.set_xlabel("Rank - descending order")
ax1.set_ylabel("Cascade size")

# Construct list of y-values. Remove 0's in the list
y_list = sorted(cascade_depth_df["cascade depth"], reverse = True)
y_list = np.array([i for i in y_list if i != 0])

# Construct list of x-values
x_list = stats.rankdata(np.negative(y_list), method = "dense")

ax2.scatter(x_list, y_list)
ax2.set_title("Cascade Depth Distribution, 2017")
ax2.set_xlabel("Rank - descending order")
ax2.set_ylabel("Cascade depth")

##### Plot cascade size for varying shock and spread parameters
# Run simulation for shock and spread parameters of 0.1, 0.5 and 0.9
fig, ax = plt.subplots(3, 3, figsize = (15, 9))

vals = [0.1, 0.5, 0.9]
for i in range(3):
    for j in range(3):
        metrics_dict = []
        # Construct dataframe of metrics per shock and spread value
        for country in countries:
            df_rows = {}
            res = sim_cascade_1(all_graphs[2017], country, shock_param = vals[i], spread_param = vals[j], k = 50)
            df_rows["Country Code"] = country
            df_rows["cascade size"] = res["cascade size"]
            df_rows["cascade depth"] = res["cascade depth"]
            metrics_dict.append(df_rows)

        metrics_df = pd.DataFrame(metrics_dict)
        
        # Construct list of y-values. Remove 0's in the list
        y_list = sorted(metrics_df["cascade size"], reverse = True)
        y_list = np.array([k for k in y_list if k != 0])

        # Construct list of x-values
        x_list = stats.rankdata(np.negative(y_list), method = "dense")

        ax[i, j].scatter(x_list, y_list)
        ax[i, j].set_title("Cascade Size Distribution, 2017 \n shock = " + str(vals[i]) + ", spread = " + str(vals[j]))
        ax[i, j].set_xlabel("Rank - descending order")
        ax[i, j].set_ylabel("Cascade size")

fig.tight_layout()        

##### Plot cascade depth for varying shock and spread parameters
# Run simulation for shock and spread parameters of 0.1, 0.5 and 0.9
fig, ax = plt.subplots(3, 3, figsize = (15, 9))

vals = [0.1, 0.5, 0.9]
for i in range(3):
    for j in range(3):
        metrics_dict = []
        # Construct dataframe of metrics per shock and spread value
        for country in countries:
            df_rows = {}
            res = sim_cascade_1(all_graphs[2017], country, shock_param = vals[i], spread_param = vals[j], k = 50)
            df_rows["Country Code"] = country
            df_rows["cascade size"] = res["cascade size"]
            df_rows["cascade depth"] = res["cascade depth"]
            metrics_dict.append(df_rows)

        metrics_df = pd.DataFrame(metrics_dict)
        
        # Construct list of y-values. Remove 0's in the list
        y_list = sorted(metrics_df["cascade depth"], reverse = True)
        y_list = np.array([k for k in y_list if k != 0])

        ax[i, j].hist(y_list, bins = [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50])
        ax[i, j].set_title("Cascade Depth Distribution, 2017 \n shock = " + str(vals[i]) + ", spread = " + str(vals[j]))

fig.tight_layout()

##### Plot cascade size vs. cascade depth for varying shock and spread parameters
# Run simulation for shock and spread parameters of 0.1, 0.5 and 0.9
fig, ax = plt.subplots(3, 3, figsize = (15, 9))

vals = [0.1, 0.5, 0.9]
for i in range(3):
    for j in range(3):
        metrics_dict = []
        # Construct dataframe of metrics per shock and spread value
        for country in countries:
            df_rows = {}
            res = sim_cascade_1(all_graphs[2017], country, shock_param = vals[i], spread_param = vals[j], k = 50)
            df_rows["Country Code"] = country
            df_rows["cascade size"] = res["cascade size"]
            df_rows["cascade depth"] = res["cascade depth"]
            metrics_dict.append(df_rows)

        metrics_df = pd.DataFrame(metrics_dict)
        
        ax[i, j].scatter(metrics_df["cascade depth"], metrics_df["cascade size"])
        ax[i, j].set_title("Cascade Size vs. Cascade Depth \n shock = " + str(vals[i]) + ", spread = " + str(vals[j]))
        ax[i, j].set_xlabel("Cascade depth")
        ax[i, j].set_ylabel("Cascade size")
        
fig.tight_layout()        

##### 4.3 Identifying Core and Peripheral Nodes
##### Calculate minimum shock parameter
min_shock_1 = {}
num_iter = 100
for country in countries:
    high = 1
    low = 0
    
    for i in range(num_iter):
        shock = (high + low) / 2
        res = sim_cascade_1(all_graphs[2017], country, shock_param = shock, spread_param = 1, k = 50)
        if res["cascade depth"] > 10:
            low = shock
        elif res["cascade depth"] <= 10:
            high = shock
            
    min_shock_1[country] = shock

# Create dataframe
min_shock_1_df = pd.DataFrame.from_dict(min_shock_1, orient = "index")
min_shock_1_df.rename(columns = {0: "shock"}, inplace = True)

# Export dataframe as csv
min_shock_1_df.to_csv(os.path.join(output_dir, "min_shock_exports.csv"), index = False)

##### Plot minimum shock rank-size distribution
# Load min_shock_exports
min_shock_1_df = pd.read_csv("Simulation Results/min_shock_exports.csv", header = 0)

# Plot distribution of minimum shock
fig, (ax1, ax2) = plt.subplots(1, 2, figsize = (10, 3))

# Construct list of y-values. Remove 0's in the list
y_list = sorted(min_shock_1_df["shock"], reverse = True)
y_list_short = np.array([i for i in y_list if i < 0.05])

# Construct list of x-values
x_list = stats.rankdata(np.negative(y_list), method = "dense")
x_list_short = stats.rankdata(np.negative(y_list_short), method = "dense")

ax1.scatter(x_list, y_list)
ax1.axhline(y = 0.8)
ax1.set_title("Minimum Shock Distribution")
ax1.set_xlabel("Rank - descending order")
ax1.set_ylabel("Minimum shock")

ax2.scatter(x_list_short, y_list_short)
ax2.axhline(y = 0.015)
ax2.set_title("Minimum Shock Distribution (for shocks $\\leq$ 0.05)")
ax2.set_xlabel("Rank - descending order")
ax2.set_ylabel("Minimum shock")

fig.tight_layout()

##### Identify core, intermediate and peripheral nodes
# Set threshold shock parameters
threshold1 = 0.8
threshold2 = 0.015
inner_core = min_shock_1_df[min_shock_1_df["shock"] <= threshold2]["Country Code"].tolist()
outer_core = min_shock_1_df[(min_shock_1_df["shock"] >= threshold2) & (min_shock_1_df["shock"] <= threshold1)]["Country Code"].tolist()
periphery = min_shock_1_df[min_shock_1_df["shock"] >= threshold1]["Country Code"].tolist()
print("inner core: ", inner_core)
print("outer core: ", outer_core)
print("periphery: ", periphery)

# Create dataframe countries_df
countries_df = pd.DataFrame(list(all_graphs[2017].nodes), columns = ["Country Code"])
countries_df["Designation"] = 0

# Add designation
for country in inner_core:
    countries_df.loc[countries_df["Country Code"] == country, "Designation"] = "inner core"

for country in outer_core:
    countries_df.loc[countries_df["Country Code"] == country, "Designation"] = "outer core"
                                                                         
for country in periphery:
    countries_df.loc[countries_df["Country Code"] == country, "Designation"] = "periphery"
    
# Remove all other countries
countries_df = countries_df[countries_df["Designation"] != 0]

##### Plot core-periphery map
# Merge geodataframe with countries_df
countries_map = gdf.merge(countries_df, how = "left", left_on = "ADM0_A3", right_on = "Country Code")

# Plot gray map
ax = countries_map.plot(color = "gray", figsize = (15, 20))

# Remove countries for which designation is neither core nor periphery
countries_map = countries_map.dropna()

# Assign number to each region
designation_mapping = {"inner core": 0, "outer core": 1, "periphery": 2}
countries_map["Designation No."] = countries_map["Designation"].apply(lambda x: designation_mapping[x])

# Plot map
countries_map.plot(column = "Designation No.", categorical = True, cmap = "jet", figsize = (15, 20), legend = True, ax = ax)
ax.set_title("Countries of the World by Designation", fontdict = {'fontsize': 20})
ax.set_axis_off()

# Modify legend
legend = ax.get_legend()
legend.set_bbox_to_anchor((.12, .4))
for i in range(len(designation_mapping)):
    legend.get_texts()[i].set_text(list(designation_mapping.keys())[i])

##### Find average centrality for core and periphery    
# Merge
countries_df = countries_df.merge(degree_df, left_on = "Country Code", right_on = "Country Code")
countries_df = countries_df.merge(strength_df, left_on = "Country Code", right_on = "Country Code")
countries_df = countries_df.merge(betweenness_df, left_on = "Country Code", right_on = "Country Code")
countries_df = countries_df.merge(eigenvector_df, left_on = "Country Code", right_on = "Country Code")

# Get summary
countries_df.groupby(["Designation"]).mean()

##### Find average link weight and normalized number of links for core and periphery
trade_desig_df = trade_df[trade_df["year"] == 2017]

# Get source - designation
trade_desig_df = trade_desig_df.merge(countries_df[["Country Code", "Designation"]], left_on = "source", right_on = "Country Code")
trade_desig_df.drop(["Country Code"], axis = 1, inplace = True)
trade_desig_df.rename(columns = {"Designation": "source - designation"}, inplace = True)

# Get target - designation
trade_desig_df = trade_desig_df.merge(countries_df[["Country Code", "Designation"]], left_on = "target", right_on = "Country Code")
trade_desig_df.drop(["Country Code"], axis = 1, inplace = True)
trade_desig_df.rename(columns = {"Designation": "target - designation"}, inplace = True)

# Get average link weight
link_weight = trade_desig_df.groupby(["source - designation", "target - designation"])["weight"].mean().reset_index(name = "average link weight")

# Display sorted table
link_weight.sort_values(by = ["average link weight"], ascending = False)

# Get count based on values in source - designation and target - designation
count = trade_desig_df.groupby(["source - designation", "target - designation"]).size().reset_index(name = "count")

# Map designations to list of countries
num_designation = {"inner core": len(inner_core), "outer core": len(outer_core), "periphery": len(periphery)}

# Get denominator
count["denom"] = np.where(count["source - designation"] == count["target - designation"], count["source - designation"].apply(lambda x: num_designation[x]) * (count["target - designation"].apply(lambda x: num_designation[x]) - 1), count["source - designation"].apply(lambda x: num_designation[x]) * count["target - designation"].apply(lambda x: num_designation[x]))

# Get normalized count
count["norm_count"] = count["count"] / count["denom"]

# Display sorted table
count[["source - designation", "target - designation", "norm_count"]].sort_values(by = ["norm_count"], ascending = False)

##### 4.3 Exposure
# Load sim1_exposure.csv as dataframe and convert to numpy array. 
exposure_df = pd.read_csv("Simulation Results/sim1_exposure.csv", index_col = 0)

# Compute for relevant values
exposure_countries_df = pd.DataFrame(list(exposure_df.columns), columns = ["Country Code"])

exposure_df["source"] = exposure_df.idxmax(axis = 0)
exposure_df["recipient"] = exposure_df.drop(["source"], axis = 1).idxmax(axis = 1)
exposure_df["maximum exposure given"] = exposure_df.max(axis = 0)
exposure_df["maximum exposure received"] = exposure_df.max(axis = 1)

exposure_countries_df = exposure_countries_df.merge(exposure_df[["source", "recipient", "maximum exposure given", "maximum exposure received"]], left_on = "Country Code", right_on = exposure_df.index)

exposure_df.drop(["source", "recipient", "maximum exposure given", "maximum exposure received"], axis = 1, inplace = True)

# Get top 10 countries
exposure_df.loc["PHL", :].sort_values(ascending = False).head(10)
exposure_df.loc[:, "PHL"].sort_values(ascending = False).head(10)

##### 4. SHOCK PROPAGATION (SUPPLY-SIDE INCREASE)
##### Code shock propagation function
# Get neigbors with respect to in-edges of all nodes
def neighbor_in(graph):
    neighbor_dict = {}

    for node in list(graph.nodes):
        neighbor_list = []
        for source, target in list(graph.in_edges(node)):
            neighbor_list.append(source)
        neighbor_dict[node] = neighbor_list
    
    return neighbor_dict

def sim_cascade_2(graph, start_node, k, shock_param, spread_param, kmax = 50):
    # Initialize matrices
    countries = list(graph.nodes)
    nc = len(countries)
    neighbors = neighbor_in(graph)
    
    trade = np.zeros((kmax + 1, nc, nc), dtype = 'float64')
    imports = np.zeros((kmax + 1, nc), dtype = 'float64')
    transfer = np.zeros((nc, nc), dtype = 'float64')
    shocks_prev = np.zeros(nc, dtype = 'float64')
    
    # Initialize trade matrix
    adj = np.asarray(nx.adjacency_matrix(graph).todense())
    trade[0, :, :] = adj.copy()
    imports[0, :] = np.sum(trade[0, :, :], axis = 0)
        
    # Initialize transfer matrix and then normalize
    transfer = trade[0, :, :]
    col_sums = np.sum(transfer, axis = 0)
    transfer = np.divide(transfer, col_sums, where = col_sums != 0)
    transfer = np.nan_to_num(transfer)
    
    # Initialize variables for the metrics
    cascade_depth = 0
    cascade_nodes = []
    exposure_arr = np.zeros(nc, dtype = 'float64')
    
    # Main loop
    for step in range(1, k + 1):
        # Initialize matrices
        temp_imports = np.zeros(nc, dtype = 'float64')
        delta_imports = np.zeros(nc, dtype = 'float64')
        delta_trade = np.zeros((nc, nc), dtype = 'float64')
        shocked = np.zeros((nc, nc), dtype = 'float64')
        shocks = np.zeros(nc, dtype = 'float64')
        
        # Initial shock
        if step == 1:
            # Initialize shock matrix
            for neighbor in neighbors[start_node]:
                shocked[countries.index(neighbor), countries.index(start_node)] = 1
            
            # Get all "children" of the start_node (i.e., all neighbors wrt outgoing edges)
            children = neighbors[start_node]
            
            # Initial shock: decrease imports of start_node by shock_param
            shocks[countries.index(start_node)] = shock_param * imports[0, countries.index(start_node)]
        
        # Subsequent shocks
        else:
            # Initialize children_placeholder
            children_placeholder = []
            
            # Run through all the children's neighbors. Store the neighbors of these neighbors in children_placeholder
            for child in children:
                for neighbor in neighbors[child]:
                    shocked[countries.index(neighbor), countries.index(child)] = 1
                    children_placeholder.append(neighbor)
            
            # Replace children with children_placeholder
            children = list(set(children_placeholder))
            
            # Subsequent shocks: decrease imports of affected nodes by spread_param
            shocks = shocks_prev * spread_param
        
        # Allocate shock to trade partners
        delta_trade = transfer * shocked * shocks
        delta_imports = np.sum(delta_trade, axis = 0)
        
        # Store all shocks received by each country in this iteration for reference in next iteration
        shocks_prev = np.sum(delta_trade, axis = 1)
        
        # Store new imports in temp_imports.
        temp_imports = imports[step - 1, :] - delta_imports
        
        if np.any(temp_imports < 0):
            # Get exposure for all countries. 
            shock_init = shock_param * imports[0, countries.index(start_node)]
                
            if shock_init > 0:
                exposure_arr = (imports[1, :] - temp_imports) / shock_init
            else:
                exposure_arr = imports[1, :] - temp_imports # list of zeroes
        
            # Zero out exposure for start_node
            #exposure_arr[countries.index(start_node)] = 0
                
            # Stop if there are negative imports.
            break
            
        else:
            # Update trade and export matrices
            imports[step, :] = imports[step - 1, :] - delta_imports
            trade[step, :, :] = trade[step - 1, :] - delta_trade
        
            # Update transfer matrix
            transfer = trade[step, :, :]
            col_sums = np.sum(transfer, axis = 0)
            transfer = np.divide(transfer, col_sums, where = col_sums != 0)
            transfer = np.nan_to_num(transfer)
            
            # Update cascade depth
            cascade_depth += 1
            
            # Update cascade_nodes
            cascade_nodes.extend(children)
    
    return {"imports": imports, "cascade depth": cascade_depth, "cascade size": len(set(cascade_nodes)), "exposure": exposure_arr}

##### Run shock propagation function for all countries
def run_sim_cascade_2(graph, start_node, k):
    # Initialize variables
    countries = list(graph.nodes)
    nc = len(countries)
    iter_count = 0
    res_total = {"cascade depth": 0, "cascade size": 0, "exposure": np.zeros(nc, dtype = 'float64')}
    
    # Run for all possible values in parameter space
    for shock in np.arange(0, 1, 0.1):
        for spread in np.arange(0, 1, 0.1):
            iter_count += 1
            res = sim_cascade_2(graph, start_node, k, shock, spread)
            res_total["cascade depth"] += res["cascade depth"]
            res_total["cascade size"] += res["cascade size"]
            res_total["exposure"] += res["exposure"]
    
    # Average all metrics
    res_ave = {key: val / iter_count for key, val in res_total.items()}
    
    return res_ave

# Find cascade size, depth and exposure for all countries
graphs = all_graphs[2017] 
countries = list(graphs.nodes)
nc = len(countries)
all_cascade_sizes = {}
all_cascade_depths = {}
exposure_mat = np.zeros((nc, nc), dtype = 'float64')

# Map cascade sizes and depths to countries
for country in countries:
    res = run_sim_cascade_2(graph = graphs, start_node = country, k = 50)
    all_cascade_sizes[country] = res["cascade size"]
    all_cascade_depths[country] = res["cascade depth"]
    exposure_mat[countries.index(country), :] = res["exposure"]
    
# Convert dictionaries (and matrix) to dataframes
cascade_size_df = pd.DataFrame.from_dict(all_cascade_sizes, orient = "index")
cascade_size_df.rename(columns = {0: "cascade size"}, inplace = True)

cascade_depth_df = pd.DataFrame.from_dict(all_cascade_depths, orient = "index")
cascade_depth_df.rename(columns = {0: "cascade depth"}, inplace = True)

exposure_df = pd.DataFrame(data = exposure_mat.astype(np.float))
exposure_df.set_axis(countries, axis = 0, inplace = True)
exposure_df.set_axis(countries, axis = 1, inplace = True)

# Reset index
cascade_size_df.reset_index(inplace = True)
cascade_size_df.rename(columns = {"index": "Country Code"}, inplace = True)

cascade_depth_df.reset_index(inplace = True)
cascade_depth_df.rename(columns = {"index": "Country Code"}, inplace = True)

# Create outgoing directory
output_dir = "./Simulation Results"
if not os.path.exists(output_dir):
    os.mkdir(output_dir)

# Write to csv files
cascade_size_df.to_csv(os.path.join(output_dir, "sim2_cascade_size.csv"), index = False)
cascade_depth_df.to_csv(os.path.join(output_dir, "sim2_cascade_depth.csv"), index = False)
exposure_df.to_csv(os.path.join(output_dir, "sim2_exposure.csv"))

##### 5.2 Distribution of Cascade Size and Depth
##### Plot cascade size and depth map
# Read cascade_size and cascade_depth dataframes
cascade_size_df = pd.read_csv("Simulation Results/sim2_cascade_size.csv", index_col = None, header = 0)
cascade_depth_df = pd.read_csv("Simulation Results/sim2_cascade_depth.csv", index_col = None, header = 0)

# Merge
cascade_df = cascade_size_df.merge(cascade_depth_df, left_on = "Country Code", right_on = "Country Code")

# Merge with geodataframe
cascade_map = gdf.merge(cascade_df, how = "left", left_on = "ADM0_A3", right_on = "Country Code")
    
# Plot gray map
fig, (ax_size, ax_depth) = plt.subplots(1, 2, figsize = (16, 20))
cascade_map.plot(color = "gray", ax = ax_size)
cascade_map.plot(color = "gray", ax = ax_depth)

# Remove countries for which cascade size = 0 or cascade depth = 0.
cascade_map = cascade_map[(cascade_map["cascade size"] != 0) & (cascade_map["cascade depth"] != 0)]

# Legend axis
divider_size = make_axes_locatable(ax_size)
cax_size = divider_size.append_axes("right", size = "5%", pad = 0.1)
divider_depth = make_axes_locatable(ax_depth)
cax_depth = divider_depth.append_axes("right", size = "5%", pad = 0.1)   

# Plot choropleth layer
cascade_map.dropna().plot(column = "cascade size", cmap = "Blues", legend = True, ax = ax_size, cax = cax_size)
ax_size.set_title("Cascade Size Map for " + str(year), fontdict = {'fontsize': 20})
ax_size.set_axis_off()
    
cascade_map.dropna().plot(column = "cascade depth", cmap = "Blues", legend = True, ax = ax_depth, cax = cax_depth)
ax_depth.set_title("Cascade Depth Map for " + str(year), fontdict = {'fontsize': 20})
ax_depth.set_axis_off()

##### Plot cascade size vs. cascade depth for varying shock and spread parameters
# Run simulation for shock and spread parameters of 0.1, 0.5 and 0.9
fig, ax = plt.subplots(3, 3, figsize = (15, 9))

vals = [0.1, 0.5, 0.9]
for i in range(3):
    for j in range(3):
        metrics_dict = []
        # Construct dataframe of metrics per shock and spread value
        for country in countries:
            df_rows = {}
            res = sim_cascade_2(all_graphs[2017], country, shock_param = vals[i], spread_param = vals[j], k = 50)
            df_rows["Country Code"] = country
            df_rows["cascade size"] = res["cascade size"]
            df_rows["cascade depth"] = res["cascade depth"]
            metrics_dict.append(df_rows)

        metrics_df = pd.DataFrame(metrics_dict)

        ax[i, j].scatter(metrics_df["cascade depth"], metrics_df["cascade size"])
        ax[i, j].set_title("Cascade Size vs. Cascade Depth \n shock = " + str(vals[i]) + ", spread = " + str(vals[j]))
        ax[i, j].set_xlabel("Cascade depth")
        ax[i, j].set_ylabel("Cascade size")
        
fig.tight_layout()

##### 5.3 Identifying Core and Peripheral Nodes
##### Calculate minimum shock parameter
min_shock_2 = {}
num_iter = 100
for country in countries:
    high = 1
    low = 0
    
    for i in range(num_iter):
        shock = (high + low) / 2
        res = sim_cascade_2(all_graphs[2017], country, shock_param = shock, spread_param = 1, k = 50)
        if res["cascade depth"] > 10:
            low = shock
        elif res["cascade depth"] <= 10:
            high = shock
            
    min_shock_2[country] = shock
    
min_shock_2_df = pd.DataFrame.from_dict(min_shock_2, orient = "index")
min_shock_2_df.rename(columns = {0: "shock"}, inplace = True)
min_shock_2_df.reset_index(inplace = True)
min_shock_2_df.rename(columns = {"index": "Country Code"}, inplace = True)
min_shock_2_df.to_csv(os.path.join(output_dir, "min_shock_imports.csv"), index = False)

##### Plot minimum shock rank-size distribution
# Load min_shock_exports
min_shock_2_df = pd.read_csv("Simulation Results/min_shock_imports.csv", header = 0)

# Plot distribution
fig, (ax1, ax2) = plt.subplots(1, 2, figsize = (10, 3))

# Construct list of y-values. Remove 0's in the list
y_list = sorted(min_shock_2_df["shock"], reverse = True)
y_list_short = np.array([i for i in y_list if i < 0.25])

# Construct list of x-values
x_list = stats.rankdata(np.negative(y_list), method = "dense")
x_list_short = stats.rankdata(np.negative(y_list_short), method = "dense")

ax1.scatter(x_list, y_list)
ax1.axhline(y = 0.8)
ax1.set_title("Minimum Shock Distribution")
ax1.set_xlabel("Rank - descending order")
ax1.set_ylabel("Minimum shock")

ax2.scatter(x_list_short, y_list_short)
ax2.axhline(y = 0.15)
ax2.set_title("Minimum Shock Distribution (for shocks $\\leq$ 0.25)")
ax2.set_xlabel("Rank - descending order")
ax2.set_ylabel("Minimum shock")

fig.tight_layout()

##### Identify core, intermediate and peripheral nodes
# Set threshold shock parameters
threshold1 = 0.8
threshold2 = 0.150
inner_core = min_shock_2_df[min_shock_2_df["shock"] <= threshold2]["Country Code"].tolist()
outer_core = min_shock_2_df[(min_shock_2_df["shock"] > threshold2) & (min_shock_2_df["shock"] <= threshold1)]["Country Code"].tolist()
periphery = min_shock_2_df[min_shock_2_df["shock"] > threshold1]["Country Code"].tolist()
print("inner core: ", inner_core)
print("outer core: ", outer_core)
print("periphery: ", periphery)

# Create dataframe countries_df
countries_df = pd.DataFrame(list(all_graphs[2017].nodes), columns = ["Country Code"])
countries_df["Designation"] = 0

# Add designation
for country in core:
    countries_df.loc[countries_df["Country Code"] == country, "Designation"] = "inner core"

for country in intermediate:
    countries_df.loc[countries_df["Country Code"] == country, "Designation"] = "outer core"
    
for country in periphery:
    countries_df.loc[countries_df["Country Code"] == country, "Designation"] = "periphery"

# Remove all other countries
countries_df = countries_df[countries_df["Designation"] != 0]

##### Plot core-periphery map
# Merge geodataframe with countries_df
countries_map = gdf.merge(countries_df, how = "left", left_on = "ADM0_A3", right_on = "Country Code")

# Plot gray map
ax = countries_map.plot(color = "gray", figsize = (15, 20))

# Remove countries for which designation is neither core nor periphery
countries_map = countries_map.dropna()

# Assign number to each region
designation_mapping = {"inner core": 0, "outer core": 1, "periphery": 2}
countries_map["Designation No."] = countries_map["Designation"].apply(lambda x: designation_mapping[x])

# Plot map
countries_map.plot(column = "Designation No.", categorical = True, cmap = "jet", figsize = (15, 20), legend = True, ax = ax)
ax.set_title("Countries of the World by Designation", fontdict = {'fontsize': 20})
ax.set_axis_off()

# Modify legend
legend = ax.get_legend()
legend.set_bbox_to_anchor((.12, .4))
for i in range(len(designation_mapping)):
    legend.get_texts()[i].set_text(list(designation_mapping.keys())[i])

##### Compute average centrality for core and periphery
# Merge
countries_df = countries_df.merge(degree_df, left_on = "Country Code", right_on = "Country Code")
countries_df = countries_df.merge(strength_df, left_on = "Country Code", right_on = "Country Code")
countries_df = countries_df.merge(betweenness_df, left_on = "Country Code", right_on = "Country Code")
countries_df = countries_df.merge(eigenvector_df, left_on = "Country Code", right_on = "Country Code")

# Get summary
countries_df.groupby(["Designation"]).mean()

##### Compute average link weight and normalized number of links for core and periphery
trade_desig_df = trade_df[trade_df["year"] == 2017]

# Get source - designation
trade_desig_df = trade_desig_df.merge(countries_df[["Country Code", "Designation"]], left_on = "source", right_on = "Country Code")
trade_desig_df.drop(["Country Code"], axis = 1, inplace = True)
trade_desig_df.rename(columns = {"Designation": "source - designation"}, inplace = True)

# Get target - designation
trade_desig_df = trade_desig_df.merge(countries_df[["Country Code", "Designation"]], left_on = "target", right_on = "Country Code")
trade_desig_df.drop(["Country Code"], axis = 1, inplace = True)
trade_desig_df.rename(columns = {"Designation": "target - designation"}, inplace = True)

# Get average link weight
link_weight = trade_desig_df.groupby(["source - designation", "target - designation"])["weight"].mean().reset_index(name = "average link weight")

# Display sorted table
link_weight.sort_values(by = ["average link weight"], ascending = False)

# Get count based on values in source - designation and target - designation
count = trade_desig_df.groupby(["source - designation", "target - designation"]).size().reset_index(name = "count")

# Map designations to list of countries
num_designation = {"inner core": len(inner_core), "outer core": len(outer_core), "periphery": len(periphery)}

# Get denominator
count["denom"] = np.where(count["source - designation"] == count["target - designation"], count["source - designation"].apply(lambda x: num_designation[x]) * (count["target - designation"].apply(lambda x: num_designation[x]) - 1), count["source - designation"].apply(lambda x: num_designation[x]) * count["target - designation"].apply(lambda x: num_designation[x]))

# Get normalized count
count["norm_count"] = count["count"] / count["denom"]

# Display sorted table
count[["source - designation", "target - designation", "norm_count"]].sort_values(by = ["norm_count"], ascending = False)

##### 5.4 Exposure
# Load sim2_exposure.csv as dataframe and convert to numpy array. 
exposure_df = pd.read_csv("Simulation Results/sim2_exposure.csv", index_col = 0)

# Compute average and maximum exposure
exposure_countries_df = pd.DataFrame(list(exposure_df.columns), columns = ["Country Code"])

exposure_df["source"] = exposure_df.idxmax(axis = 0)
exposure_df["recipient"] = exposure_df.drop(["source"], axis = 1).idxmax(axis = 1)
exposure_df["maximum exposure given"] = exposure_df.max(axis = 0)
exposure_df["maximum exposure received"] = exposure_df.max(axis = 1)

exposure_countries_df = exposure_countries_df.merge(exposure_df[["source", "recipient", "maximum exposure given", "maximum exposure received"]], left_on = "Country Code", right_on = exposure_df.index)

exposure_df.drop(["source", "recipient", "maximum exposure given", "maximum exposure received"], axis = 1, inplace = True)

# Get top 10 countries
exposure_df.loc["PHL", :].sort_values(ascending = False).head(10)
exposure_df.loc[:, "PHL"].sort_values(ascending = False).head(10)

##### 6. MINIMUM SHOCK VS CENTRALITY
# Merge
min_shock = min_shock_1_df.merge(min_shock_2_df, left_on = "Country Code", right_on = "Country Code", suffixes = ("_1", "_2"))
min_shock = min_shock.merge(in_eigenvector_df, left_on = "Country Code", right_on = "Country Code")
min_shock = min_shock.merge(out_eigenvector_df, left_on = "Country Code", right_on = "Country Code")
min_shock = min_shock.merge(in_strength_df, left_on = "Country Code", right_on = "Country Code")
min_shock = min_shock.merge(out_strength_df, left_on = "Country Code", right_on = "Country Code")
min_shock = min_shock.merge(betweenness_df, left_on = "Country Code", right_on = "Country Code")

# Plot minimum shock vs centrality
fig, ax = plt.subplots(3, 2, figsize = (10, 9))

ax[0, 0].scatter(np.log(min_shock["out-strength"]), np.log(min_shock["shock_1"]))
ax[0, 0].set_title("Minimum Shock (Supply-Side Decrease) vs. Out-Strength Centrality")
ax[0, 0].set_xlabel("Log of Out-Strength Centrality")
ax[0, 0].set_ylabel("Log of Minimum Shock")

ax[0, 1].scatter(np.log(min_shock["in-strength"]), np.log(min_shock["shock_2"]))
ax[0, 1].set_title("Minimum Shock (Supply-Side Increase) vs. In-Strength Centrality")
ax[0, 1].set_xlabel("Log of In-Strength Centrality")
ax[0, 1].set_ylabel("Log of Minimum Shock")

ax[1, 0].scatter(np.log(min_shock["out-eigenvector"]), np.log(min_shock["shock_1"]))
ax[1, 0].set_title("Minimum Shock (Supply-Side Decrease) vs. Out-Eigenvector Centrality")
ax[1, 0].set_xlabel("Log of Out-Eigenvector Centrality")
ax[1, 0].set_ylabel("Log of Minimum Shock")

ax[1, 1].scatter(np.log(min_shock["in-eigenvector"]), np.log(min_shock["shock_2"]))
ax[1, 1].set_title("Minimum Shock (Supply-Side Increase) vs. In-Eigenvector Centrality")
ax[1, 1].set_xlabel("Log of In-Eigenvector Centrality")
ax[1, 1].set_ylabel("Log of Minimum Shock")

ax[2, 0].scatter(np.log(min_shock["betweenness"]), np.log(min_shock["shock_1"]))
ax[2, 0].set_title("Minimum Shock (Supply-Side Decrease) vs. Betweenness Centrality")
ax[2, 0].set_xlabel("Log of Betweenness Centrality")
ax[2, 0].set_ylabel("Log of Minimum Shock")

ax[2, 1].scatter(np.log(min_shock["betweenness"]), np.log(min_shock["shock_2"]))
ax[2, 1].set_title("Minimum Shock (Supply-Side Increase) vs. Betweenness Centrality")
ax[2, 1].set_xlabel("Log of Betweenness Centrality")
ax[2, 1].set_ylabel("Log of Minimum Shock")

fig.tight_layout()