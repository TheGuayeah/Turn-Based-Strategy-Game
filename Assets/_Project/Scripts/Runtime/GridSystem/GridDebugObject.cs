using TMPro;
using UnityEngine;

public class GridDebugObject : MonoBehaviour
{
   [SerializeField]
   private TextMeshPro textMeshPro;

   private object gridObject;

   protected virtual void Update()
   {
      textMeshPro.text = gridObject.ToString();
   }

   public virtual void SetGridObject(object gridObject)
   {
      this.gridObject = gridObject;
   }
}
