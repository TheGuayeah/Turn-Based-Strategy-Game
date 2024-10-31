using System;
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
      Ray ray = Camera.main.ScreenPointToRay(InputManager.Instance.GetMouseScreenPosition());
      Physics.Raycast(ray, out RaycastHit hitInfo, float.MaxValue, Instance.unignoredPositions);
      return hitInfo.point;
   }

   public static Vector3 GetPositionOnlyHitVisible()
   {
      Ray ray = Camera.main.ScreenPointToRay(InputManager.Instance.GetMouseScreenPosition());
      RaycastHit[] raycastHits = Physics.RaycastAll(
         ray, 
         float.MaxValue, 
         Instance.unignoredPositions
      );

      Array.Sort(raycastHits, (RaycastHit hitA, RaycastHit hitB) =>
      {
         return Mathf.RoundToInt(hitA.distance - hitB.distance);
      });

      foreach (RaycastHit hitInfo in raycastHits)
      {
         if (hitInfo.transform.TryGetComponent(out Renderer renderer))
         {
            if (renderer.enabled)
            {
               return hitInfo.point;
            }
         }
      }

      return Vector3.zero;
   }
}
