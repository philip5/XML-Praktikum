declare variable $s1 := fn:doc("mancala.xml")//slot[@ID>=0 and @ID<6];
declare variable $s2 := fn:doc("mancala.xml")//slot[@ID>=7 and @ID<13];

(: Calculates the sum of all counters in the 'Slot' Sequence $s  :)
declare function local:summe($s) {
  fn:sum(for $c in $s/count return fn:data($c))
};

declare function local:getHouse($id) {
  fn:doc("mancala.xml")//slot[@ID = $id]
};



(: Checks if the game has ended // Returns 1 if the row of slots of player 1 is empty
   and returns 2 if the second player's row is empty :)
declare function local:finishedCheck() { 
            (if (local:summe($s1) = 0) then 1
             else if ((local:summe($s2) = 0)) then 2
             else 0)
};

(: Self Explanatory :)
declare function local:removeStones($id) {
    let $house := local:getHouse($id)
    return <slot type = "{$house/@type}" ID = '{$id}'>
            {$house/owner}
            <count>{0}</count>
             {$house/pos}
            </slot>
};

declare function local:test($id) {
  
};

declare function local:pickHouse($afterID) {
      
     let $c := fn:doc("mancala.xml")//slot[@ID = $afterID]/data(count)
     for $s in fn:doc("mancala.xml")//slot
     return (  
            if (($afterID + $c) > 13) then
              (if (($s/@ID < $afterID) and ($s/@ID > ($afterID + $c) mod 14)) then $s 
              
              else if ($s/@ID = $afterID) then 
              local:removeStones($afterID)
                    
              else 
              <slot type = "{$s/@type}" ID = '{$s/@ID}'>
                  {$s/owner}
                  <count>{$s/data(count) + 1}</count>
                  {$s/pos}
              </slot> 
              )
            else (if (($s/@ID < $afterID) or ($s/@ID > ($afterID + $c))) then $s
                  else if ($s/@ID = $afterID) then 
                    local:removeStones($afterID)
              
                  else 
                  <slot type = "{$s/@type}" ID = '{$s/@ID}'>
                      {$s/owner}
                      <count>{$s/data(count) + 1}</count>
                      {$s/pos}
                  </slot>  ) 
            )
             
};

let $doc := doc("mancala.xml")
let $fName := fn:concat ("C:\mancala", data($doc/game/gameID), ".xml")
let $result := (<game>
                  <gameID>0</gameID>
                  <finished>{local:finishedCheck()}</finished>   
                  {local:pickHouse(12)}
              </game>)

return $result