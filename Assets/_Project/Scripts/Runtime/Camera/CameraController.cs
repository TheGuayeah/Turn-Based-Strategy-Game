using Cinemachine;
using System.Collections;
using UnityEngine;

public class CameraController : Singleton<CameraController>
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
   private float zoomIncreaseAmount = 1f;
   [SerializeField]
   private float zoomSpeed = 5f;
   [SerializeField]
   private AnimationCurve moveToUnitCurve;

   private CinemachineTransposer transposer;
   //[SerializeField]
   private Vector3 targetFollowOffset;

   protected override void Awake()
   {
      base.Awake();
   }

   private void Start()
   {
      UnitActionSystem.Instance.OnSelectedUnitChanged += Instance_OnSelectedUnitChanged;
      transposer = virtualCamera.GetCinemachineComponent<CinemachineTransposer>();
      targetFollowOffset = transposer.m_FollowOffset;
      MoveToSelectedUnit();
   }

   private void Update()
   {
      HandleMovement();
      HandleRotation();
      HandleZoom();
   }

   private void Instance_OnSelectedUnitChanged(object sender, System.EventArgs e)
   {
      MoveToSelectedUnit();
   }

   public void FollowSelectedUnit()
   {
      Unit selectedUnit = UnitActionSystem.Instance.GetSelectedUnit();

      transform.position = Vector3.MoveTowards(
         transform.position,
         selectedUnit.transform.position,
         moveSpeed * Time.deltaTime
      );
   }

   public void MoveToSelectedUnit()
   {
      Unit selectedUnit = UnitActionSystem.Instance.GetSelectedUnit();
      Vector3 endPosition = selectedUnit.transform.position;

      if (transform.position == selectedUnit.transform.position) return;

      StartCoroutine(LerpPosition(endPosition, 0.5f));
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
      Vector2 inputMoveDir = InputManager.Instance.GetCameraMoveVector();

      Vector3 moveVector = transform.forward * inputMoveDir.y +
                           transform.right * inputMoveDir.x;
      transform.position += moveVector * moveSpeed * Time.deltaTime;
   }

   private void HandleRotation()
   {
      Vector3 rotationVector = InputManager.Instance.GetCameraRotateVector();

      transform.eulerAngles += rotationVector * rotationSpeed * Time.deltaTime;
   }

   private void HandleZoom()
   {
      zoomIncreaseAmount = 1f;
      targetFollowOffset.y += 
         InputManager.Instance.GetCameraZoomAmount() * zoomIncreaseAmount;

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

   public float GetCameraHeight()
   {
      return targetFollowOffset.y;
   }
}
