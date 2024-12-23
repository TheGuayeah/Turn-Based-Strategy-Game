using System;
using System.Collections.Generic;
using UnityEngine;

public class SpinAction : BaseAction
{
   private float totalAngle;

   private void Update()
   {
      if (!isActive) return;

      float angle = 360f * Time.deltaTime;
      transform.eulerAngles += new Vector3(0, angle, 0);

      totalAngle += angle;
      if (totalAngle >= 360f)
      {
         ActionComplete();
      }
   }

   public override void TakeAction(GridPosition gridPosition, Action onSpinComplete)
   {
      totalAngle = 0f;
      ActionStart(onSpinComplete);
   }

   public override string GetActionName()
   {
      return "Spin";
   }

   public override List<GridPosition> GetValidActionGridPositions()
   {
      GridPosition unitGridPosition = unit.GetGridPosition();

      return new List<GridPosition>
      {
         unitGridPosition
      };
   }

   public override EnemyAIAction GetEnemyAIAction(GridPosition gridPosition)
   {
      return new EnemyAIAction
      {
         gridPosition = gridPosition,
         actionValue = 0
      };
   }
}
