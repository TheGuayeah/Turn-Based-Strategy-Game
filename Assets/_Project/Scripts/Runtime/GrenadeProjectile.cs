using System;
using UnityEngine;

public class GrenadeProjectile : MonoBehaviour
{
   [SerializeField]
   private float moveSpeed = 15f;
   [SerializeField]
   private float damageRadius = 4f;

   private Vector3 targetPosition;
   private Action onGrenadeActionComplete;

   private void Update()
   {
      Vector3 moveDirection = (targetPosition - transform.position).normalized;
      transform.position += moveDirection * moveSpeed * Time.deltaTime;

      float reachedTargetDistance = 0.2f;

      if (Vector3.Distance(transform.position, targetPosition) < reachedTargetDistance)
      {

         Collider[] colliders = Physics.OverlapSphere(targetPosition, damageRadius);

         foreach (Collider collider in colliders)
         {
            collider.TryGetComponent<Unit>(out Unit targetUnit);
            if (targetUnit == null) continue;

            targetUnit.TakeDamage(30);
         }

         Destroy(gameObject);

         onGrenadeActionComplete();
      }
   }

   public void SetUp(GridPosition targetGridPosition, Action onGrenadeActionComplete)
   {
      this.onGrenadeActionComplete = onGrenadeActionComplete;
      targetPosition = LevelGrid.Instance.GetWorldPosition(targetGridPosition);
   }
}
