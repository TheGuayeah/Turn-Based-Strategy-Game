using UnityEngine;

public class MouseWorld : Singleton<MouseWorld>
{
   [SerializeField]
   private LayerMask unignoredPositions;

   //private void Update()
   //{
   //   transform.position = GetPosition();
   //}

   public static Vector3 GetPosition()
   {
      Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
      Physics.Raycast(ray, out RaycastHit hitInfo, float.MaxValue, Instance.unignoredPositions);
      return hitInfo.point;
   }
}
