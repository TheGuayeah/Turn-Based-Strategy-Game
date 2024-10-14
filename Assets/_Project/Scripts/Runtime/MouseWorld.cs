using UnityEngine;

public class MouseWorld : Singleton<MouseWorld>
{
   [SerializeField]
   private LayerMask unignoredPositions;

   public static Vector3 GetPosition()
   {
      Ray ray = Camera.main.ScreenPointToRay(InputManager.Instance.GetMouseScreenPosition());
      Physics.Raycast(ray, out RaycastHit hitInfo, float.MaxValue, Instance.unignoredPositions);
      return hitInfo.point;
   }
}
