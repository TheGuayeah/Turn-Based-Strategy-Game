using UnityEngine;

public class InputManager : Singleton<InputManager>
{
   

   public Vector2 GetMouseScreenPosition()
   {
      return Input.mousePosition;
   }

   public bool IsMouseButtonDown(int mouseButton)
   {
      return Input.GetMouseButtonDown(mouseButton);
   }

   public Vector2 GetCameraMoveVector()
   {
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
   }

   public Vector2 GetCameraRotateVector()
   {
      Vector2 rotationVector = new Vector2(0, 0);

      if (Input.GetKey(KeyCode.Q))
      {
         rotationVector += Vector2.up;
      }
      if (Input.GetKey(KeyCode.E))
      {
         rotationVector += Vector2.down;
      }

      return rotationVector;
   }

   public float GetCameraZoomAmount()
   {
      float zoomAmmount = 0f;

      if (Input.mouseScrollDelta.y > 0)
      {
         zoomAmmount = -1f;
      }
      else if (Input.mouseScrollDelta.y < 0)
      {
         zoomAmmount = 1f;
      }

      return zoomAmmount;
   }
}
