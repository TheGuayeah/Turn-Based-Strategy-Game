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
      }
   }

   public void Spin()
   {
      isActive = true;
      totalAngle = 0f;
      Debug.Log("Spinning");
   }
}
