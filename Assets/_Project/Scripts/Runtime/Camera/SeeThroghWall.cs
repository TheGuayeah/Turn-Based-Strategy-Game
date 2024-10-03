using System.Collections;
using UnityEngine;

public class SeeThroghWall : MonoBehaviour
{
   private static int positionId = Shader.PropertyToID("_TargetPos");
   private static int sizeId = Shader.PropertyToID("_Size");

   [SerializeField]
   private Material wallMaterial;
   [SerializeField]
   private LayerMask wallLayerMask;
   [SerializeField]
   private AnimationCurve cutoutSizeCurve;

   private Camera mainCamera;

   private void Awake()
   {
      mainCamera = Camera.main;
   }

   private void Update()
   {
      Vector3 direction = mainCamera.transform.position - transform.position;
      Ray ray = new Ray(transform.position, direction.normalized);

      if (Physics.Raycast(ray, 3000, wallLayerMask))
      {
         StartCoroutine(LerpSize(0, 1, 0.5f));
      }
      else
      {
         wallMaterial.SetFloat(sizeId, 0);
      }

      Vector3 view = mainCamera.WorldToViewportPoint(transform.position);

      wallMaterial.SetVector(positionId, view);
   }

   private IEnumerator LerpSize(int startSize, int endSize, float duration)
   {
      float time = 0;

      while (time < duration)
      {
         wallMaterial.SetFloat(sizeId,
            Mathf.Lerp(
               startSize,
               endSize,
               cutoutSizeCurve.Evaluate(time / duration)
            )
         );

         time += Time.deltaTime;
         yield return null;
      }
      wallMaterial.SetFloat(sizeId, endSize);
   }
}
