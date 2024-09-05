using System;
using System.Collections.Generic;
using UnityEngine;

public class GrenadeAction : BaseAction
{
   [SerializeField]
   private Transform grenadePrefab;
   [SerializeField]
   private int maxThrowDistance = 7;
   [SerializeField]
   private LayerMask obstaclesLayerMask;

   private void Update()
   {
      if (!isActive) return;
   }

   public override string GetActionName()
   {
      return "Grenade";
   }

   public override EnemyAIAction GetEnemyAIAction(GridPosition gridPosition)
   {
      return new EnemyAIAction
      {
         gridPosition = gridPosition,
         actionValue = 0,
      };
   }

   public override List<GridPosition> GetValidActionGridPositions()
   {
      List<GridPosition> validActionGridPositions = new List<GridPosition>();
      GridPosition unitGridPosition = unit.GetGridPosition();

      for (int x = -maxThrowDistance; x <= maxThrowDistance; x++)
      {
         for (int z = -maxThrowDistance; z <= maxThrowDistance; z++)
         {
            GridPosition offsetGridPosition = new GridPosition(x, z);
            GridPosition testGridPosition = unitGridPosition + offsetGridPosition;

            if (!LevelGrid.Instance.IsValidGridPosition(testGridPosition))
            {
               continue;
            }

            int testDistance = Math.Abs(x) + Math.Abs(z);
            if (testDistance > maxThrowDistance) continue; //This position is too far away

            validActionGridPositions.Add(testGridPosition);
         }
      }

      return validActionGridPositions;
   }

   public override void TakeAction(GridPosition gridPosition, Action onActionComplete)
   {
      Transform grandeProjectileTransform = Instantiate(
         grenadePrefab, 
         unit.GetWorldPosition(), 
         Quaternion.identity, 
         transform
      );

      GrenadeProjectile grenadeProjectile = 
         grandeProjectileTransform.GetComponent<GrenadeProjectile>();

      grenadeProjectile.SetUp(gridPosition, OnGrenadeActionComplete);
      ActionStart(onActionComplete);
   }

   private void OnGrenadeActionComplete()
   {
      ActionComplete();
   }
}
