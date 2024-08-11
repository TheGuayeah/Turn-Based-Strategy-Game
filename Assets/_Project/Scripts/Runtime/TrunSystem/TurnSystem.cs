using System;
using UnityEngine;

public class TurnSystem : Singleton<TurnSystem>
{
   public event EventHandler OnTurnChanged;

   private int turnNumber;

   public void NextTurn()
   {
     turnNumber++;

      OnTurnChanged?.Invoke(this, EventArgs.Empty);
   }

   public int GetTurnNumber()
   {
      return turnNumber;
   }
}
