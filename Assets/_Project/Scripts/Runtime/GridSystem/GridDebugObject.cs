using TMPro;
using UnityEngine;

public class GridDebugObject : MonoBehaviour
{
   [SerializeField]
   private TextMeshPro textMeshPro;

   private GridObject gridObject;

   private void Update()
   {
      textMeshPro.text = gridObject.ToString();
   }

   public void SetGridObject(GridObject gridObject)
   {
      this.gridObject = gridObject;
   }
}
