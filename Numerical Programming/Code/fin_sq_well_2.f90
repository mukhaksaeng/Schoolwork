real L , lscale ,k1,k2
data L ,V0 /1.,8. /
k1(e) = (2.* (V0 -E) )**(1./2.)
k2(e)=(2.*e)**(1./2.)
!f(e) for even states
f(e)=k1(e)-k2(e)*tan(k2(e)*L)
!f(e) for odd states
!f(e)= k1(e)+ k2(e)/tan(k2(e)*L)
df(e)= (f(e+epsi)-f(e))/epsi
Lscale=1/v0**.5
epsi=lscale/100.
!initial E must be selected near an eigenvalue
e=0.5
do 10 i=1,10
e1=e - f(e)/df(e)
print*,'i, e= ', i, e
e=e1
10 continue
stop
end
