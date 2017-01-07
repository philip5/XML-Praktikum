module namespace m = "mancala/model"; 
import module namespace h = "mancala/helpers" at "helpers.xqm";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace math = "http://www.w3.org/2005/xpath-functions/math";

declare variable $m:instances := db:open("MancalaDB");
declare variable $m:default := db:open("MancalaDB")//game[@gameID="0"];

declare function m:getp1Houses($gameID) {
  $m:instances//game[@gameID = $gameID]//slot[@ID>=0 and @ID<6]
};

declare function m:getp2Houses($gameID) {
  $m:instances//game[@gameID = $gameID]//slot[@ID>=7 and @ID<13]
};

declare %private function m:newID() as xs:string {
  h:timestamp()
};

declare function m:newGame() as element(game) {
  copy $c := $m:default
  modify 
  (
    replace value of node $c/@gameID with m:newID()
  )
  return $c 
};

declare %updating function m:insertGame($game as element(game)) {
  insert node $game as last into $m:instances
};

(: Calculates the sum of all counters in the 'Slot' Sequence $s  :)
declare function m:summe($s) {
  fn:sum(for $c in $s/count return fn:data($c))
};

declare function m:getHouse($id, $gameID) {
  $m:instances//game[@gameID = $gameID]//slot[@ID=$id]
};



(: Checks if the game has ended // Returns 1 if the row of slots of player 1 is empty
   and returns 2 if the second player's row is empty :)
declare function m:finishedCheck($gameID) { 
            (if (m:summe(m:getp1Houses($gameID)) = 0) then 1
             else if ((m:summe(m:getp2Houses($gameID)) = 0)) then 2
             else 0)
};

(: Self Explanatory :)
declare function m:removeStones($id , $gameID) {
    let $house := m:getHouse($id, $gameID)
    return <slot type = "{$house/@type}" ID = '{$id}'>
            {$house/owner}
            <count>{0}</count>
             {$house/pos}
            </slot>
};

declare function m:checkPlayerTurn($houseID, $gameID) {
  let $s := $m:instances//game[@gameID = $gameID]
  let $c := $m:instances//game[@gameID=$gameID]//slot[@ID = $houseID]/data(count)
    return if ($s/curplayer = 1)then 
                (if ($houseID + $c = 6) then <curplayer>1</curplayer> 
                 else <curplayer>2</curplayer>
                ) 
           else 
                 (if ($houseID + $c = 13) then <curplayer>2</curplayer> 
                  else <curplayer>1</curplayer>)
};

declare function m:updatedGameState($houseID, $gameID) {
  let $c := $m:instances//game[@gameID=$gameID]//slot[@ID = $houseID]/data(count)
  let $s := ($houseID + $c mod 14)
  return 
  (
  <game gameID="{$gameID}" lastCount = "{$c}" lastSlotID = "{$s}">
  <finished>{m:finishedCheck($gameID)}</finished>
  {m:checkPlayerTurn($houseID, $gameID)}
  {m:pickHouse_returnSlots($houseID, $gameID)}
  </game>
  )
};

declare function m:lastVersion($game as element(game)) {
  
};

declare function m:pickHouse_returnSlots($houseID, $gameID) {
      
     let $c := $m:instances//game[@gameID=$gameID]//slot[@ID = $houseID]/data(count)
     for $s in $m:instances//game[@gameID = $gameID]//slot
     return (  
            if (($houseID + $c) > 13) then
                  (if (($s/@ID < $houseID) and ($s/@ID > ($houseID + $c) mod 14))
                   then $s 
                  
                  else if ($s/@ID = $houseID) 
                  then m:removeStones($houseID, $gameID)
                        
                  else 
                  <slot type = "{$s/@type}" ID = '{$s/@ID}'>
                      {$s/owner}
                      <count>{$s/data(count) + 1}</count>
                      {$s/pos}
                  </slot> 
                  )
            else 
                  (if (($s/@ID < $houseID) or ($s/@ID > ($houseID + $c))) then $s
                  
                  else if ($s/@ID = $houseID) 
                  then m:removeStones($houseID, $gameID)
              
                  else 
                  <slot type = "{$s/@type}" ID = '{$s/@ID}'>
                      {$s/owner}
                      <count>{$s/data(count) + 1}</count>
                      {$s/pos}
                  </slot>  
                  ) 
            )
             
};



