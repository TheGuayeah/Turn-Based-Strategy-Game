using UnityEngine;

public class BulletProjectile : MonoBehaviour
{
   [SerializeField]
   private TrailRenderer trailRenderer;
   [SerializeField]
   private Transform bulletHitVfxPrefab;
   [SerializeField]
   private float moveSpeed = 200f;

   private Vector3 targetPosition;

   private void Update()
   {
      Vector3 moveDirection = (targetPosition - transform.position).normalized;

      float distanceBeforeMoving = Vector3.Distance(transform.position, targetPosition);

      transform.position += moveDirection * moveSpeed * Time.deltaTime;

      float distanceAfterMoving = Vector3.Distance(transform.position, targetPosition);

      if (distanceBeforeMoving < distanceAfterMoving)
      {
         transform.position = targetPosition;
         trailRenderer.transform.SetParent(null);
         Destroy(gameObject);
         Instantiate(bulletHitVfxPrefab, targetPosition, Quaternion.identity);
      }
   }

   public void Setup(Vector3 targetPosition)
   {
      this.targetPosition = targetPosition;
   }
}
