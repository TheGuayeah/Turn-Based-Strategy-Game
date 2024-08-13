using System;
using System.Collections.Generic;
using UnityEngine;

public class MoveAction : BaseAction
{
   public event EventHandler OnStartMoving;
   public event EventHandler OnStopMoving;

   [SerializeField]
   private float moveSpeed = 4f;
   [SerializeField]
   private float stoppingDistance = 0.1f;
   [SerializeField]
   private float rotateSpeed = 25f;
   [SerializeField]
   private int maxMoveDistance = 4;

   private Vector3 targetPosition;

   protected override void Awake()
   {
      base.Awake();
      targetPosition = transform.position;
   }

   private void Update()
   {
      if (!isActive) return;

      float distance = Vector3.Distance(transform.position, targetPosition);
      Vector3 moveDirection = (targetPosition - transform.position).normalized;

      transform.forward = Vector3.Lerp(transform.forward, moveDirection,
                           rotateSpeed * Time.deltaTime);

      if (distance > stoppingDistance)
      {
         transform.position += moveDirection * moveSpeed * Time.deltaTime;
      }
      else
      {
         OnStopMoving?.Invoke(this, EventArgs.Empty);
         ActionComplete();
      }
   }

   public override void TakeAction(GridPosition gridPosition, Action onMoveComplete)
   {
      ActionStart(onMoveComplete);
      targetPosition = LevelGrid.Instance.GetWorldPosition(gridPosition);

      OnStartMoving?.Invoke(this, EventArgs.Empty);
   }

   public override List<GridPosition> GetValidActionGridPositions()
   {
      List<GridPosition> validActionGridPositions = new List<GridPosition>();
      GridPosition unitGridPosition = unit.GetGridPosition();

      for (int x = -maxMoveDistance; x <= maxMoveDistance; x++)
      {
         for (int z = -maxMoveDistance; z <= maxMoveDistance; z++)
         {
            GridPosition offsetGridPosition = new GridPosition(x, z);
            GridPosition testGridPosition = unitGridPosition + offsetGridPosition;

            if (!LevelGrid.Instance.IsValidGridPosition(testGridPosition))
            {
              continue;
            }

            if(unitGridPosition == testGridPosition)
            {
               continue; //The unit is already at this position.
            }

            if(LevelGrid.Instance.IsAnyUnitAtGridPosition(testGridPosition))
            {
               continue; //There is already a unit at this position.
            }

            validActionGridPositions.Add(testGridPosition);
         }
      }

      return validActionGridPositions;
   }

   public override string GetActionName()
   {
      return "Move";
   }
}
