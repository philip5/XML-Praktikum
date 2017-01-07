module namespace m = "mancala/model"; 
import module namespace h = "mancala/helpers" at "mancalaHelpers.xqm";

declare variable $m:instances := db:open("MancalaDB");
declare variable $m:default := db:open("MancalaDB")//game[@gameID="0"];

declare %private function m:getp1Houses($gameID) {
  $m:instances//game[@gameID = $gameID]//slot[@ID>=0 and @ID<6]
};

declare %private function m:getp2Houses($gameID) {
  $m:instances//game[@gameID = $gameID]//slot[@ID>=7 and @ID<13]
};

declare %private function m:newID() as xs:string {
  h:timestamp()
};

declare function m:newGame() as element(game) {
  copy $c := $m:default
  modify 
    replace value of node $c/@gameID with m:newID()
  return $c 
};

declare %updating function m:insertGame($game as element(game)) {
  insert node $game as last into $m:instances
};

(: Calculates the sum of all counters in the 'Slot' Sequence $s  :)
declare %private function m:sumCounters($s) {
  fn:sum(for $c in $s/count return fn:data($c))
};

declare function m:getHouse($id, $gameID) {
  $m:instances//game[@gameID = $gameID]//slot[@ID=$id]
};



(: Checks if the game has ended // Returns 1 if the row of slots of player 1 is empty
   and returns 2 if the second player's row is empty :)
declare %private function m:finishedCheck($gameID) { 
  if(m:sumCounters(m:getp1Houses($gameID)) = 0) then 
      1
  else 
  if(m:sumCounters(m:getp2Houses($gameID)) = 0) then 
      2
  else 
      0
};

declare function m:finishedUpdate($gameID) {
  (::)
};

(: Self Explanatory :)
declare %private function m:removeStones($id , $gameID) {
  copy $c := m:getHouse($id, $gameID)
  modify
    replace value of node $c/count with 0
  return $c 
};

declare %private function m:checkPlayerTurn($clickedHouseID, $gameID) {
  let $s := $m:instances//game[@gameID = $gameID]
  let $c := $m:instances//game[@gameID=$gameID]//slot[@ID = $clickedHouseID]/data(count)
    return
      if($s/curplayer = 1) then 
          if($clickedHouseID + $c = 6) then
              <curplayer>1</curplayer> 
          else 
              <curplayer>2</curplayer>
      else
          if($clickedHouseID + $c = 13) then 
              <curplayer>2</curplayer> 
          else 
              <curplayer>1</curplayer>
};

(: Returns the new game state in xml format after the player clicks on a house, but 
    does not consider the opposite house rule // This is done by the 'updatedGameState'
    method, which does the final check and applies the opposite house rule:)
declare function m:intermediateGameState($clickedHouseID, $gameID) {
  let $c := $m:instances//game[@gameID=$gameID]//slot[@ID = $clickedHouseID]/data(count)
  let $s := ($clickedHouseID + $c mod 14)
  return
    <game gameID="{$gameID}" lastCount = "{$c}" clickedHouseID = "{$clickedHouseID}">
    <finished>{m:finishedCheck($gameID)}</finished>
    {m:checkPlayerTurn($clickedHouseID, $gameID)}
    {m:moveStones($clickedHouseID, $gameID)}
    </game>
};


(: Receives as input the output of m:intermediateGameState and checks if the 
   opposite house rule applies. Returns the xml representation of the game state
   after a single player move :)
declare function m:finalGameState ($game as element(game)) {
  let $clickedHouse := $game//slot[@ID = $game/@clickedHouseID]
  let $landedHouse := $game//slot[@ID = ($game/@clickedHouseID + $game/@lastCount)]
  return
    if ($clickedHouse/owner = $landedHouse/owner and $landedHouse/data(count) = 1) then 
        copy $c := $game
        modify 
          let $oppositeHouse := $c//slot[@ID = 12 - $landedHouse/@ID]
          let $store := 
              if($clickedHouse/owner = 1) then 
                  $c//slot[@ID = 6] 
              else 
                  $c//slot[@ID = 13]
          return ( 
            replace value of node $store/count with $store/data(count) + $oppositeHouse/data(count),
            replace value of node $oppositeHouse/count with 0
          ) 
        return $c                   
    else $game
};

  (:Applies the changes of the updated game state to the database:)
declare %updating function m:executeMove($clickedHouseID,$gameID) {
  replace node $m:instances//game[@gameID = $gameID] with (m:finalGameState(m:intermediateGameState($clickedHouseID, $gameID)))
};

declare %updating function m:checkGameOver($gameID) {
  if($m:instances//game[@gameID = $gameID]/data(finished) = 1) then 
        (replace value of node $m:instances//game[@gameID = $gameID]//slot[@ID = 13]/count with 
        (48 - $m:instances//game[@gameID = $gameID]//slot[@ID = 6]/data(count)),
        m:emptyRow(2,$gameID))
    else if($m:instances//game[@gameID = $gameID]//data(finished) = 2) then 
        (replace value of node $m:instances//game[@gameID = $gameID]//slot[@ID = 6]/count with 
        (48 - $m:instances//game[@gameID = $gameID]//slot[@ID = 13]/data(count)),
         m:emptyRow(1,$gameID))
    else 
        replace node $m:instances with $m:instances
};

declare %updating function m:emptyRow($owner, $gameID) {
  for $s in $m:instances//game[@gameID=$gameID]//slot[@ID != 13 and @ID != 6]
  where $s/owner = $owner
  return replace value of node $s/count with 0
};
  (:Empties the clicked house and then moves the stones accordingly
    Returns a sequence of all the slots (houses and stores) with updated counts
  :)
declare %private function m:moveStones($clickedHouseID, $gameID) {
  let $c := $m:instances//game[@gameID=$gameID]//slot[@ID = $clickedHouseID]/data(count)
  for $s in $m:instances//game[@gameID = $gameID]//slot
  return 
    if(($clickedHouseID + $c) > 13) then 
        if(($s/@ID < $clickedHouseID) and ($s/@ID > (($clickedHouseID + $c) mod 14))) then 
            $s 
        else if ($s/@ID = $clickedHouseID) then 
            m:removeStones($clickedHouseID, $gameID)  
        else
            copy $c := $s
            modify 
            (
              replace value of node $c/count with $s/data(count) + 1
            )
            return $c
    else 
        if(($s/@ID < $clickedHouseID) or ($s/@ID > ($clickedHouseID + $c))) then 
            $s 
        else if ($s/@ID = $clickedHouseID) then 
            m:removeStones($clickedHouseID, $gameID)
        else 
            copy $c := $s
            modify 
            (
              replace value of node $c/count with $s/data(count) + 1
            )
            return $c     
};



