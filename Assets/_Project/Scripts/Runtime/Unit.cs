using UnityEngine;

public class Unit : MonoBehaviour
{
   [SerializeField]
   private float moveSpeed = 4f;
   [SerializeField]
   private float stoppingDistance = 0.1f;

   private Vector3 targetPosition;

   private void Update()
   {
      float distance = Vector3.Distance(transform.position, targetPosition);

      if(distance > stoppingDistance)
      {
         Vector3 moveDirection = (targetPosition - transform.position).normalized;
         transform.position += moveDirection * moveSpeed * Time.deltaTime;
      }

      if (Input.GetMouseButtonDown(0))
      {
         Move(MouseWorld.GetPosition());
      }
   }

   private void Move(Vector3 _targetPosition)
   {
      targetPosition = _targetPosition;
   }
}
