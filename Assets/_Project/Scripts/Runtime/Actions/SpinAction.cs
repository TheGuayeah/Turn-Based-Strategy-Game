using System;
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
         isActive = false;
         onActionComplete();
      }
   }

   public void Spin(Action onSpinComplete)
   {
      onActionComplete = onSpinComplete;
      isActive = true;
      totalAngle = 0f;
   }

   public override string GetActionName()
   {
      return "Spin";
   }
}
