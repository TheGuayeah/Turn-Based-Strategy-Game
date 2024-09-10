using System;
using UnityEngine;
using UnityEngine.UIElements;

public class GrenadeProjectile : MonoBehaviour
{
   public static event EventHandler OnAnyGrenadeExploded;

   [SerializeField]
   private Transform grenadeExplodeVfxPrefab;
   [SerializeField]
   private TrailRenderer trailRenderer;
   [SerializeField]
   private float moveSpeed = 15f;
   [SerializeField]
   private float damageRadius = 4f;
   [SerializeField]
   private AnimationCurve arcYAnimationCurve;

   private Vector3 targetPosition;
   private Action onGrenadeActionComplete;
   private float totalDistance;
   private Vector3 positionXZ;

   private void Update()
   {
      Vector3 moveDirection = (targetPosition - positionXZ).normalized;
      positionXZ += moveDirection * moveSpeed * Time.deltaTime;

      float distance = Vector3.Distance(positionXZ, targetPosition);
      float distanceNormalized = 1 - distance / totalDistance;
      float maxHeight = totalDistance / 4f;
      float positionY = arcYAnimationCurve.Evaluate(distanceNormalized) * maxHeight;

      transform.position = new Vector3(positionXZ.x, positionY, positionXZ.z);

      float reachedTargetDistance = 0.2f;

      if (distance < reachedTargetDistance)
      {

         Collider[] colliders = Physics.OverlapSphere(targetPosition, damageRadius);

         foreach (Collider collider in colliders)
         {
            collider.TryGetComponent<Unit>(out Unit targetUnit);
            if (targetUnit == null) continue;

            targetUnit.TakeDamage(30);
         }

         OnAnyGrenadeExploded?.Invoke(this, EventArgs.Empty);

         trailRenderer.transform.SetParent(null);

         Instantiate(
            grenadeExplodeVfxPrefab, 
            targetPosition + Vector3.up * 1f, 
            Quaternion.identity
         );

         Destroy(gameObject);

         onGrenadeActionComplete();
      }
   }

   public void SetUp(GridPosition targetGridPosition, Action onGrenadeActionComplete)
   {
      this.onGrenadeActionComplete = onGrenadeActionComplete;
      targetPosition = LevelGrid.Instance.GetWorldPosition(targetGridPosition);

      positionXZ = transform.position;
      positionXZ.y = 0;
      totalDistance = Vector3.Distance(positionXZ, targetPosition);
   }
}
