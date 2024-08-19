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
      return false;
   }

   private bool TryTakeEnemyAIAction(Unit enemyUnit, Action onEnemyAIActionComplete)
   {
      SpinAction spinAction = enemyUnit.GetSpinAction();

      GridPosition actionGridPosition = enemyUnit.GetGridPosition();

      if (!spinAction.IsValidActionGridPosition(actionGridPosition)) return false;

      if (!enemyUnit.TrySpendActionPoints(spinAction)) return false;

      spinAction.TakeAction(actionGridPosition, onEnemyAIActionComplete);
      return true;
   }
}
