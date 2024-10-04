using System;
using Unity.VisualScripting;
using UnityEngine;

public class EnemyAI : MonoBehaviour
{
   public enum State
   {
      WaitingForEnemyTurn,
      TakingTurn,
      Busy
   }

   private State state;
   private float timer;

   private void Awake()
   {
      state = State.WaitingForEnemyTurn;
   }

   private void Start()
   {
      TurnSystem.Instance.OnTurnChanged += TurnSystem_OnTurnChanged;
   }

   private void Update()
   {
      if (TurnSystem.Instance.IsPlayerTurn()) return;

      switch (state)
      {
         case State.WaitingForEnemyTurn:
            break;
         case State.TakingTurn:
            timer -= Time.deltaTime;
            if (timer <= 0)
            {
               if (TryTakeEnemyAIAction(SetStateTakingTurn))
               {
                  state = State.Busy;
               }
               else //No more enemies can take an action
               {                  
                  TurnSystem.Instance.NextTurn();
               }
            }
            break;
         case State.Busy:
            break;
         default:
            break;
      }
   }

   private void SetStateTakingTurn()
   {
      timer = 0.5f;
      state = State.TakingTurn;
   }

   private void TurnSystem_OnTurnChanged(object sender, EventArgs e)
   {
      if (TurnSystem.Instance.IsPlayerTurn()) return;

      if (sender.GetType() == typeof(TurnSystem))
      {
         if (UnitManager.Instance.GetEnemyUnits().Count == 0) return;

         Unit nextEnemyUnit = UnitManager.Instance.GetEnemyUnits()[0];
         UnitActionSystem.Instance.SetSelectedUnit(nextEnemyUnit);
      }

      state = State.TakingTurn;
      timer = 2f;
   }

   private bool TryTakeEnemyAIAction(Action onEnemyAIActionComplete)
   {
      foreach (Unit enemyUnit in UnitManager.Instance.GetEnemyUnits())
      {
         if (TryTakeEnemyAIAction(enemyUnit, onEnemyAIActionComplete))
         {
            return true;
         }
      }

      if (UnitManager.Instance.GetFriendlyUnits().Count == 0) return false;

      Unit nextFriendlyUnit = UnitManager.Instance.GetFriendlyUnits()[0];
      UnitActionSystem.Instance.SetSelectedUnit(nextFriendlyUnit);
      
      return false;
   }

   private bool TryTakeEnemyAIAction(Unit enemyUnit, Action onEnemyAIActionComplete)
   {
      EnemyAIAction bestEnemyAIAction = null;
      BaseAction bestAction = null;

      foreach (BaseAction action in enemyUnit.GetBaseActions())
      {
         if (!enemyUnit.HasEnoughActionPoints(action))
         {
            continue;
         }

         if(bestEnemyAIAction == null)
         {
            bestEnemyAIAction = action.GetBestEnemyAIAction();
            bestAction = action;
         }
         else
         {
            EnemyAIAction newEnemyAIAction = action.GetBestEnemyAIAction();
            if (newEnemyAIAction != null &&
               newEnemyAIAction.actionValue > bestEnemyAIAction.actionValue)
            {
               bestEnemyAIAction = newEnemyAIAction;
               bestAction = action;
            }
         }
      }

      if (bestEnemyAIAction != null &&
         enemyUnit.TrySpendActionPoints(bestAction))
      {
         bestAction.TakeAction(
            bestEnemyAIAction.gridPosition, onEnemyAIActionComplete);
         return true;
      }
      else
      {
         return false;
      }
   }
}
