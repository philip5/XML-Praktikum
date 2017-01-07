import module namespace h = "mancala/helpers" at "helpers.xqm";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace math = "http://www.w3.org/2005/xpath-functions/math";

declare variable $instances := db:open("MancalaDB");

let $s := $instances
return $s