using System.Collections.Generic;
using UnityEngine;

public class FloorVisibility : MonoBehaviour
{
   [SerializeField]
   private bool dynamicFloorPosition;
   [SerializeField]
   private List<Renderer> ignoredRenderers;
   [SerializeField]
   private List<CanvasRenderer> ignoredCanvas;

   private Renderer[] renderers;
   private int floor;

   private void Awake()
   {
      renderers = GetComponentsInChildren<Renderer>(true);
   }

   private void Start()
   {
      floor = LevelGrid.Instance.GetFloor(transform.position);

      if (floor == 0 && !dynamicFloorPosition)
      {
         Destroy(this);
      }
   }

   private void Update()
   {
      if (dynamicFloorPosition)
      {
         floor = LevelGrid.Instance.GetFloor(transform.position);
      }

      float cameraHeight = CameraController.Instance.GetCameraHeight();
      float floorHeightOffset = 2f;
      bool showObject = cameraHeight > LevelGrid.FLOOR_HEIGHT * floor + floorHeightOffset;

      if (showObject || floor == 0) Show();
      else Hide();
   }

   private void Show()
   {
      foreach (Renderer renderer in renderers)
      {
         if (ignoredRenderers.Contains(renderer)) continue;
         renderer.enabled = true;
      }

      foreach (CanvasRenderer canvas in ignoredCanvas)
      {
         canvas.SetAlpha(1);
      }
   }

   private void Hide()
   {
      foreach (Renderer renderer in renderers)
      {
         if (ignoredRenderers.Contains(renderer)) continue;
         renderer.enabled = false;
      }

      foreach (CanvasRenderer canvas in ignoredCanvas)
      {
         canvas.SetAlpha(0);
      }
   }
}
