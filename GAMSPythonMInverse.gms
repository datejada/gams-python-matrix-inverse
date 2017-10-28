Set i /bus1*bus3/
Alias (i,j,k)

Parameter
   Ybus   (i,j)
   YbusInv(i,j);

Table Ybus(i,j)
         bus1 bus2 bus3
   bus1   1    2    3
   bus2  11    0   13
   bus3  21    2   23;

$onEmbeddedCode Python:
 import numpy as np

 i = list(gams.get("i"))
 i_idx = dict(zip(i,range(len(i))))

 b = np.matrix(np.zeros(shape=(len(i),len(i))))
 for r in gams.get("YBus", keyFormat=KeyFormat.FLAT):
  b[i_idx[r[0]],i_idx[r[1]]] = r[2]

 print('\nb:\n',b)
 bInv = np.linalg.pinv(b)
 print('\nbInv:\n',bInv)

 bInvList = []
 for idx, x in np.ndenumerate(bInv):
   if abs(x)>1e-9:
     bInvList.append((i[idx[0]],i[idx[1]],x))

 gams.set("YbusInv",bInvList)
$offEmbeddedCode YbusInv


display Ybus;
display YbusInv;

alias (i,ip,jp);
parameter id(i,j);
id(i,j) = round(sum(k, YBus(i,k)*YBusInv(k,j)),8);
display id;

set err(i,j);
err(i,j) = id(i,j) <> 1$sameas(i,j);
abort$card(err) err;

