using Cinemachine;
using System.Collections;
using UnityEngine;

public class CameraController : MonoBehaviour
{
   private const float MIN_FOLLOW_Y_OFFSET = 2f;
   private const float MAX_FOLLOW_Y_OFFSET = 22f;

   [SerializeField]
   private CinemachineVirtualCamera virtualCamera;
   [SerializeField]
   private float moveSpeed = 10f;
   [SerializeField]
   private float rotationSpeed = 100f;
   [SerializeField]
   private float zoomAmmount = 1f;
   [SerializeField]
   private float zoomSpeed = 5f;
   [SerializeField]
   private AnimationCurve moveToUnitCurve;

   private CinemachineTransposer transposer;
   //[SerializeField]
   private Vector3 targetFollowOffset;

   private void Start()
   {
      transposer = virtualCamera.GetCinemachineComponent<CinemachineTransposer>();
      targetFollowOffset = transposer.m_FollowOffset;
   }

   private void Update()
   {
      HandleMovement();
      HandleRotation();
      HandleZoom();

      if (UnitActionSystem.Instance.IsUnitBeingSelected())
      {
         MoveToSelectedUnit();
      }
   }

   private void MoveToSelectedUnit()
   {
      Vector3 endPosition = 
         UnitActionSystem.Instance.GetSelectedUnit().transform.position;
      StartCoroutine(LerpPosition(endPosition, 0.7f));

      if (transform.position == endPosition)
      {
         UnitActionSystem.Instance.ClearUnitBeingSelected();
      }
   }

   private IEnumerator LerpPosition(Vector3 targetPosition, float duration)
   {
      float time = 0;
      Vector3 startPosition = transform.position;

      while (time < duration)
      {
         transform.position = Vector3.Lerp(
            startPosition,
            targetPosition,
            moveToUnitCurve.Evaluate(time / duration)
         );

         time += Time.deltaTime;
         yield return null;
      }
      transform.position = targetPosition;
   }

   private void HandleMovement()
   {
      Vector3 inputMoveDir = new Vector3(0, 0, 0);

      if (Input.GetKey(KeyCode.W))
      {
         inputMoveDir += Vector3.forward;
      }
      if (Input.GetKey(KeyCode.S))
      {
         inputMoveDir += Vector3.back;
      }
      if (Input.GetKey(KeyCode.A))
      {
         inputMoveDir += Vector3.left;
      }
      if (Input.GetKey(KeyCode.D))
      {
         inputMoveDir += Vector3.right;
      }

      Vector3 moveVector = transform.forward * inputMoveDir.z +
                           transform.right * inputMoveDir.x;
      transform.position += moveVector * moveSpeed * Time.deltaTime;
   }

   private void HandleRotation()
   {
      Vector3 rotationVector = new Vector3(0, 0, 0);

      if (Input.GetKey(KeyCode.Q))
      {
         rotationVector += Vector3.up;
      }
      if (Input.GetKey(KeyCode.E))
      {
         rotationVector += Vector3.down;
      }

      transform.eulerAngles += rotationVector * rotationSpeed * Time.deltaTime;
   }

   private void HandleZoom()
   {
      if (Input.mouseScrollDelta.y > 0)
      {
         targetFollowOffset.y -= zoomAmmount;
      }
      else if (Input.mouseScrollDelta.y < 0)
      {
         targetFollowOffset.y += zoomAmmount;
      }

      targetFollowOffset.y = Mathf.Clamp(
         targetFollowOffset.y,
         MIN_FOLLOW_Y_OFFSET,
         MAX_FOLLOW_Y_OFFSET
      );

      transposer.m_FollowOffset = Vector3.Lerp(
         transposer.m_FollowOffset,
         targetFollowOffset,
         zoomSpeed * Time.deltaTime
      );
   }
}
