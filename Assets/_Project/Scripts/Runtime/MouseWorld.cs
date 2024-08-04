using UnityEngine;

public class MouseWorld : Singleton<MouseWorld>
{
   [SerializeField]
   private LayerMask mousePlaneLayerMask;

   public static Vector3 GetPosition()
   {
      Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
      Physics.Raycast(ray, out RaycastHit hitInfo, float.MaxValue, Instance.mousePlaneLayerMask);
      return hitInfo.point;
   }
}
