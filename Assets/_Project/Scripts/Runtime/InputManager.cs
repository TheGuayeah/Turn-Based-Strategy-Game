#define USE_NEW_INPUT_SYSTEM
using UnityEngine;
using UnityEngine.InputSystem;

public class InputManager : Singleton<InputManager>
{
   private PlayerInputActions playerInputActions;

   protected override void Awake()
   {
      base.Awake();
      playerInputActions = new PlayerInputActions();
      playerInputActions.Player.Enable();
   }

   public Vector2 GetMouseScreenPosition()
   {
#if USE_NEW_INPUT_SYSTEM
      return Mouse.current.position.ReadValue();
#else
      return Input.mousePosition;
#endif
   }

   public bool IsMouseButtonDownThisFrame(int mouseButton)
   {
#if USE_NEW_INPUT_SYSTEM
      return playerInputActions.Player.Click.WasPressedThisFrame();
#else
      return Input.GetMouseButtonDown(mouseButton);
#endif
   }

   public Vector2 GetCameraMoveVector()
   {
#if USE_NEW_INPUT_SYSTEM
      return playerInputActions.Player.CameraMovement.ReadValue<Vector2>();
#else
      Vector2 inputMoveDir = new Vector3(0, 0);

      if (Input.GetKey(KeyCode.W))
      {
         inputMoveDir += Vector2.up;
      }
      if (Input.GetKey(KeyCode.S))
      {
         inputMoveDir += Vector2.down;
      }
      if (Input.GetKey(KeyCode.A))
      {
         inputMoveDir += Vector2.left;
      }
      if (Input.GetKey(KeyCode.D))
      {
         inputMoveDir += Vector2.right;
      }

      return inputMoveDir;
#endif
   }

   public Vector2 GetCameraRotateVector()
   {
      Vector2 rotationVector = new Vector2(0, 0);

#if USE_NEW_INPUT_SYSTEM
      rotationVector.y = playerInputActions.Player.CameraRotate.ReadValue<float>();
#else
      if (Input.GetKey(KeyCode.Q))
      {
         rotationVector += Vector2.up;
      }
      if (Input.GetKey(KeyCode.E))
      {
         rotationVector += Vector2.down;
      }
#endif
      return rotationVector;
   }

   public float GetCameraZoomAmount()
   {
      float zoomAmmount = 0f;

#if USE_NEW_INPUT_SYSTEM
      zoomAmmount = playerInputActions.Player.CameraZoom.ReadValue<float>();
#else

      if (Input.mouseScrollDelta.y > 0)
      {
         zoomAmmount = -1f;
      }
      else if (Input.mouseScrollDelta.y < 0)
      {
         zoomAmmount = 1f;
      }
#endif
      return zoomAmmount;
   }
}
