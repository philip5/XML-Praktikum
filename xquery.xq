for $m in doc("mancala.xml")/game
let $house := $m/house
where $house/count > 1
return $house