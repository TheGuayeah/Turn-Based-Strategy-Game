using System;
using System.Collections.Generic;
using UnityEngine;

public class ShootAction : BaseAction
{
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

            transform.forward = Vector3.Lerp(transform.forward, aimDirection,
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
      OnShoot?.Invoke(this, new OnShootEventArgs
      {
         targetUnit = targetUnit,
         shootingUnit = unit
      });
      targetUnit.TakeDamage();
   }

   public override string GetActionName()
   {
      return "Shoot";
   }

   public override List<GridPosition> GetValidActionGridPositions()
   {
      List<GridPosition> validActionGridPositions = new List<GridPosition>();
      GridPosition unitGridPosition = unit.GetGridPosition();

      for (int x = -maxShootDistance; x <= maxShootDistance; x++)
      {
         for (int z = -maxShootDistance; z <= maxShootDistance; z++)
         {
            GridPosition offsetGridPosition = new GridPosition(x, z);
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

            //This Unit can shoot only enemies
            //if (targetUnit.IsEnemy() == unit.IsEnemy()) continue;

            validActionGridPositions.Add(testGridPosition);
         }
      }

      return validActionGridPositions;
   }

   public override void TakeAction(GridPosition gridPosition, Action onShootComplete)
   {
      ActionStart(onShootComplete);

      targetUnit = LevelGrid.Instance.GetUnitFromGridPosition(gridPosition);

      state = State.Aiming;
      float aimingDuration = 1f;
      stateTimer = aimingDuration;

      canShoot = true;
   }
}
