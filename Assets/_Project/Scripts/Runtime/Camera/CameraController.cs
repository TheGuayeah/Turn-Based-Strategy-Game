using Cinemachine;
using UnityEngine;
using UnityEngine.EventSystems;

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

   private CinemachineTransposer transposer;
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
      transposer.m_FollowOffset = Vector3.Lerp(transposer.m_FollowOffset,
         targetFollowOffset,
         zoomSpeed * Time.deltaTime
      );
   }
}
