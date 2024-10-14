using System;
using System.Collections.Generic;
using UnityEngine;

public class InteractAction : BaseAction
{
   [SerializeField]
   private int maxInteractDistance = 1;

   private void Update()
   {
      if (!isActive) return;
   }

   public override string GetActionName()
   {
      return "Interact";
   }

   public override EnemyAIAction GetEnemyAIAction(GridPosition gridPosition)
   {
      return new EnemyAIAction
      {
         gridPosition = gridPosition,
         actionValue = 0
      };
   }

   public override List<GridPosition> GetValidActionGridPositions()
   {
      List<GridPosition> validActionGridPositions = new List<GridPosition>();
      GridPosition unitGridPosition = unit.GetGridPosition();

      for (int x = -maxInteractDistance; x <= maxInteractDistance; x++)
      {
         for (int z = -maxInteractDistance; z <= maxInteractDistance; z++)
         {
            GridPosition offsetGridPosition = new GridPosition(x, z);
            GridPosition testGridPosition = unitGridPosition + offsetGridPosition;

            if (!LevelGrid.Instance.IsValidGridPosition(testGridPosition))
            {
               continue;
            }

            if (LevelGrid.Instance.IsAnyUnitAtGridPosition(testGridPosition))
            {
               continue; //This position has a Unit.
            }

            IInteractable interactable = LevelGrid.Instance.GetInteractableFromGridPsoition(testGridPosition);

            if (interactable == null) continue;

            validActionGridPositions.Add(testGridPosition);
         }
      }

      return validActionGridPositions;
   }

   public override void TakeAction(GridPosition gridPosition, Action onActionComplete)
   {
      IInteractable interactable = 
         LevelGrid.Instance.GetInteractableFromGridPsoition(gridPosition);

      interactable.Interact(OnInteractionComplete);

      ActionStart(onActionComplete);
   }

   private void OnInteractionComplete()
   {
      ActionComplete();
   }
}