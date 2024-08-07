using UnityEngine;

public class Unit : MonoBehaviour
{
   private const string ANIMATOR_IS_WALKING = "IsWalking";

   [SerializeField]
   private Animator unitAnimator;
   [SerializeField]
   private float moveSpeed = 4f;
   [SerializeField]
   private float rotateSpeed = 25f;
   [SerializeField]
   private float stoppingDistance = 0.1f;

   private Vector3 targetPosition;
   private GridPosition gridPosition;

   private void Awake()
   {
      targetPosition = transform.position;
   }

   private void Start()
   {
      gridPosition = LevelGrid.Instance.GetGridPosition(transform.position);
      LevelGrid.Instance.AddUnitAtGridPosition(gridPosition, this);
   }

   private void Update()
   {
      float distance = Vector3.Distance(transform.position, targetPosition);

      if(distance > stoppingDistance)
      {
         Vector3 moveDirection = (targetPosition - transform.position).normalized;

         transform.forward = Vector3.Lerp(transform.forward, moveDirection, 
                              rotateSpeed * Time.deltaTime);

         transform.position += moveDirection * moveSpeed * Time.deltaTime;
         unitAnimator.SetBool(ANIMATOR_IS_WALKING, true);
      }
      else
      {
         unitAnimator.SetBool(ANIMATOR_IS_WALKING, false);
      }

      GridPosition newGridPosition = LevelGrid.Instance.GetGridPosition(transform.position);

      if(newGridPosition != gridPosition)
      {
         LevelGrid.Instance.UnitMovedGridPosition(this, gridPosition, newGridPosition);
         gridPosition = newGridPosition;
      }
   }

   public void Move(Vector3 newTargetPosition)
   {
      targetPosition = newTargetPosition;
   }
}
