xquery version "1.0";

(: find an node in the xml:)
declare function local:findID($id){
for $m in doc("mancala.xml")/game/slot
where $m[@ID = $id ]
return $m};

(: add stones to other existing stones by replacing the old value with the old value + new stones:)declare %updating function local:addStones($id, $stones){
for $m in local:findID($id)
return(replace value of node $m/count with ($m/count+$stones))};

(:Replacing existing stones completly with new stones e.g. to delete them:)
declare %updating function local:setStones($id, $stones as xs:integer){
for $m in local:findID($id)
return(replace value of node $m/count with ($stones))};

(: Set all nodes to a given count :)
declare  %updating function local:resetAllStones($stones){
for $m in doc("mancala.xml")/game/slot
return(replace value of node $m/count with ($stones))};

(: if the last stone is on a former emtpy house than the opposite stones goes to the players store
but doesn't work because a node can only be changed once in a query, has to be called from somewhere else:)
declare %updating function local:emptyHouseToStore($id,$player){
  let $opposite := 14-$id
  let $stonesInTheHouse := local:findID($opposite)/count
  
  for $sharedId in(0 to 13)
  return
  (
    if($sharedId = $id) then local:addStones($sharedId,1)
    else if($sharedId = $opposite) then local:setStones($sharedId,0)
    else if($sharedId = 0 and $player = 1) then local:addStones($sharedId,$stonesInTheHouse)
    else if($sharedId = 7 and $player = 2) then local:addStones($sharedId,$stonesInTheHouse)
    else local:addStones($sharedId,0)
  )
};
(: our definde pickHouse method... Picks Stones from house and share it on the next houses, works fine except the emptyHouseToStore method has to be deleted:)
declare %updating function local:pickHouse($id,$player){
let $m := local:findID($id)
let $id := xs:integer($id)
let $counter := $m/count+ $id
for $sharedId in(0 to 13)
return(
  if($sharedId != $id) then (
      if($sharedId = $counter mod 14) 
      then if(local:findID($sharedId)/count = 0 and local:findID($sharedId)[@type = "house"])then				 local:emptyHouseToStore($sharedId,$player)
        else local:addStones($sharedId,1)
      else if($sharedId < $id and $sharedId > ($counter mod 14))then 
          local:addStones($sharedId,0)
            else local:addStones($sharedId,1)
  )
  else local:setStones($sharedId,0)
)};

(: another safe and working method which just picks and shares, but does not delete stones in the origin house:)
declare %updating function local:pickHouse2($id,$player){
let $m := local:findID($id)
let $id := xs:integer($id)
let $counter := $m/count
for $sharedId in(1 to $counter)
return local:addStones(($id+$sharedId) mod 14,1)
};

declare variable $stones := 4;
declare variable $id :="8";
declare variable $playerID := 1;
local:pickHouse($id,$playerID)