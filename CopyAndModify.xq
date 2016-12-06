xquery version "1.0";
declare function local:copy3($x) {
 copy $c := doc("mancala.xml")
modify (
  for $d in $c//*:Point
  return insert node (
    <extrude>1</extrude>,
    <altitudeMode>relativeToGround</altitudeMode>
  )  before $d/*:coordinates
)
return $c
};



for $x in doc("mancala.xml")
where $x
  return file:append("/Users/Philip/Documents/XML-Praktikum/XML-Praktikum/mancala.xml",  local:copy3($x))