using System;
using System.Collections.Generic;
using UnityEngine;

public class ShootAction : BaseAction
{
   public static event EventHandler<OnShootEventArgs> OnAnyShoot;
   public event EventHandler<OnShootEventArgs> OnShoot;

   public class OnShootEventArgs : EventArgs
   {
      public Unit targetUnit;
      public Unit shootingUnit;
   }

   [SerializeField]
   private int maxShootDistance = 7;
   [SerializeField]
   private float rotateSpeed = 25f;
   [SerializeField]
   private LayerMask obstaclesLayerMask;

   private enum State
   {
      Aiming,
      Shooting,
      Cooldown
   }

   private State state;
   private float stateTimer;
   private Unit targetUnit;
   private bool canShoot;

   private void Update()
   {
      if (!isActive) return;

      stateTimer -= Time.deltaTime;

      switch (state)
      {
         case State.Aiming:
            Vector3 aimDirection = (targetUnit.GetWorldPosition() - 
                                    unit.GetWorldPosition()).normalized;
            aimDirection.y = 0f;

            transform.forward = Vector3.Slerp(transform.forward, aimDirection,
                                 rotateSpeed * Time.deltaTime);
            break;

         case State.Shooting:
            if (canShoot)
            {
               Shoot();
               canShoot = false;
            }
            break;

         case State.Cooldown:
            
            break;

         default:
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
         case State.Aiming:
            state = State.Shooting;
            float shootDuration = 0.1f;
            stateTimer = shootDuration;
            break;

         case State.Shooting:
            state = State.Cooldown;
            float cooldownDuration = 0.5f;
            stateTimer = cooldownDuration;
            break;

         case State.Cooldown:
            ActionComplete();
            break;

         default:
            break;
      }
   }

   private void Shoot()
   {
      OnAnyShoot?.Invoke(this, new OnShootEventArgs
      {
         targetUnit = targetUnit,
         shootingUnit = unit
      });
      OnShoot?.Invoke(this, new OnShootEventArgs
      {
         targetUnit = targetUnit,
         shootingUnit = unit
      });
      GetValidActionGridPositions();
      targetUnit.TakeDamage(40);
   }

   public override string GetActionName()
   {
      return "Shoot";
   }

   public override List<GridPosition> GetValidActionGridPositions()
   {
      GridPosition unitGridPosition = unit.GetGridPosition();
      return GetValidActionGridPositions(unitGridPosition);
   }

   public List<GridPosition> GetValidActionGridPositions(GridPosition unitGridPosition)
   {
      List<GridPosition> validActionGridPositions = new List<GridPosition>();
      int floorAmount = LevelGrid.Instance.GetFloorAmount();

      for (int x = -maxShootDistance; x <= maxShootDistance; x++)
      {
         for (int z = -maxShootDistance; z <= maxShootDistance; z++)
         {
            for (int floor = -floorAmount; floor <= floorAmount; floor++)
            {
               GridPosition offsetGridPosition = new GridPosition(x, z, floor);
               GridPosition testGridPosition = unitGridPosition + offsetGridPosition;

               if (!LevelGrid.Instance.IsValidGridPosition(testGridPosition))
               {
                  continue;
               }

               int testDistance = Math.Abs(x) + Math.Abs(z);
               if (testDistance > maxShootDistance) continue; //This position is too far away

               if (!LevelGrid.Instance.IsAnyUnitAtGridPosition(testGridPosition))
               {
                  continue; //This position has no Unit.
               }

               Unit targetUnit = LevelGrid.Instance.GetUnitFromGridPosition(testGridPosition);

               //This EnemyUnit can shoot only FriendlyUnits
               if (targetUnit.IsEnemy() && unit.IsEnemy()) continue;
               //This Unit can shoot only enemies
               //if (targetUnit.IsEnemy() == unit.IsEnemy()) continue;

               if (targetUnit == unit) continue;

               if (IsGridPositionBlockedByObstacle(
                  testGridPosition,
                  obstaclesLayerMask
               )) continue;

               validActionGridPositions.Add(testGridPosition);
            }
         }
      }

      return validActionGridPositions;
   }

   public override void TakeAction(GridPosition gridPosition, Action onShootComplete)
   {
      targetUnit = LevelGrid.Instance.GetUnitFromGridPosition(gridPosition);

      state = State.Aiming;
      float aimingDuration = 1f;
      stateTimer = aimingDuration;

      canShoot = true;

      ActionStart(onShootComplete);
   }

   public Unit GetTargetUnit()
   {
      return targetUnit;
   }

   public int GetMaxShootDistance()
   {
      return maxShootDistance;
   }

   public override EnemyAIAction GetEnemyAIAction(GridPosition gridPosition)
   {
      Unit targetUnit = LevelGrid.Instance.GetUnitFromGridPosition(gridPosition);

      return new EnemyAIAction
      {
         gridPosition = gridPosition,
         actionValue = 100 + Mathf.RoundToInt(targetUnit.GetHealthNormalized() * 100f)
      };
   }

   public int GetTargetCountAtPosition(GridPosition gridPosition)
   {
      List<GridPosition> validActionGridPositions = 
         GetValidActionGridPositions(gridPosition);

      return validActionGridPositions.Count;
   }
}
