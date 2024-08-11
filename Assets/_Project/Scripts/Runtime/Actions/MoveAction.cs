using System;
using System.Collections.Generic;
using UnityEngine;

public class MoveAction : BaseAction
{
   private const string ANIMATOR_IS_WALKING = "IsWalking";

   [SerializeField]
   private Animator unitAnimator;
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
         unitAnimator.SetBool(ANIMATOR_IS_WALKING, true);
      }
      else
      {
         unitAnimator.SetBool(ANIMATOR_IS_WALKING, false);
         isActive = false;
         onActionComplete();
      }
   }

   public void Move(GridPosition gridPosition, Action onMoveComplete)
   {
      onActionComplete = onMoveComplete;
      targetPosition = LevelGrid.Instance.GetWorldPosition(gridPosition);
      isActive = true;
   }

   public bool IsValidActionGridPosition(GridPosition gridPosition)
   {
      List<GridPosition> validGridPositions = GetVelidActionGridPositions();
      return validGridPositions.Contains(gridPosition);
   }

   /// <summary>
   /// Checks which grid positions are valid for the unit to move to.
   /// </summary>
   /// <returns></returns>
   public List<GridPosition> GetVelidActionGridPositions()
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
}
