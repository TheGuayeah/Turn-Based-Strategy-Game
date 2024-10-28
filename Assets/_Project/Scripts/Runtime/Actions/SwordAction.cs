using System;
using System.Collections.Generic;
using UnityEngine;

public class SwordAction : BaseAction
{
   public static event EventHandler OnAnySwordHit;

   public event EventHandler OnSwordActionStarted;
   public event EventHandler OnSwordActionCompleted;

   [SerializeField]
   private int maxSwordDistance = 1;
   [SerializeField]
   private float rotateSpeed = 25f;
   [SerializeField]
   private int swordDamage = 100;

   private enum State
   {
      SwingingSwordBeforeHit,
      SwingingSwordAfterHit,
   }

   private State state;
   private float stateTimer;
   private Unit targetUnit;

   private void Update()
   {
      if (!isActive) return;

      stateTimer -= Time.deltaTime;

      switch (state)
      {
         case State.SwingingSwordBeforeHit:
            Vector3 aimDirection = (targetUnit.GetWorldPosition() -
                                    unit.GetWorldPosition()).normalized;

            transform.forward = Vector3.Slerp(transform.forward, aimDirection,
                                 rotateSpeed * Time.deltaTime);
            break;

         case State.SwingingSwordAfterHit:
            
            break;
      }

      if (stateTimer <= 0)
      {
         NextState();
      }
   }

   private void NextState()
   {
      switch (state)
      {
         case State.SwingingSwordBeforeHit:
            state = State.SwingingSwordAfterHit;
            float afterHitStateTime = 0.5f;
            stateTimer = afterHitStateTime;
            targetUnit.TakeDamage(swordDamage);
            OnAnySwordHit?.Invoke(this, EventArgs.Empty);
            break;

         case State.SwingingSwordAfterHit:
            OnSwordActionCompleted?.Invoke(this, EventArgs.Empty);
            ActionComplete();
            break;
      }
   }

   public override string GetActionName()
   {
      return "Sword";
   }

   public override EnemyAIAction GetEnemyAIAction(GridPosition gridPosition)
   {
      return new EnemyAIAction
      {
         gridPosition = gridPosition,
         actionValue = 200,
      };
   }

   public override List<GridPosition> GetValidActionGridPositions()
   {
      List<GridPosition> validActionGridPositions = new List<GridPosition>();
      GridPosition unitGridPosition = unit.GetGridPosition();

      for (int x = -maxSwordDistance; x <= maxSwordDistance; x++)
      {
         for (int z = -maxSwordDistance; z <= maxSwordDistance; z++)
         {
            GridPosition offsetGridPosition = new GridPosition(x, z, 0);
            GridPosition testGridPosition = unitGridPosition + offsetGridPosition;

            if (!LevelGrid.Instance.IsValidGridPosition(testGridPosition))
            {
               continue;
            }

            if (!LevelGrid.Instance.IsAnyUnitAtGridPosition(testGridPosition))
            {
               continue; //This position has no Unit.
            }

            Unit targetUnit = LevelGrid.Instance.GetUnitFromGridPosition(testGridPosition);

            if (targetUnit == unit) continue;

            //This EnemyUnit can attack only FriendlyUnits
            if (targetUnit.IsEnemy() && unit.IsEnemy()) continue;
            //This Unit can attack only enemies
            //if (targetUnit.IsEnemy() == unit.IsEnemy()) continue;

            validActionGridPositions.Add(testGridPosition);
         }
      }

      return validActionGridPositions;
   }

   public override void TakeAction(GridPosition gridPosition, Action onActionComplete)
   {
      targetUnit = LevelGrid.Instance.GetUnitFromGridPosition(gridPosition);
      state = State.SwingingSwordBeforeHit;
      float beforeHitStateTime = 0.7f;
      stateTimer = beforeHitStateTime;

      OnSwordActionStarted?.Invoke(this, EventArgs.Empty);

      ActionStart(onActionComplete);
   }

   public int GetMaxSwordDistance()
   {
      return maxSwordDistance;
   }
}
