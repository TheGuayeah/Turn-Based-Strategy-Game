using UnityEngine;
using TMPro;

public class PathfindingGridDebugObject : GridDebugObject
{
   [SerializeField]
   private TextMeshPro gCostText;
   [SerializeField]
   private TextMeshPro hCostText;
   [SerializeField]
   private TextMeshPro fCostText;
   [SerializeField]
   private SpriteRenderer isWalkableSprite;

   private PathNode pathNode;

   protected override void Update()
   {
      base.Update();
      gCostText.text = "G: " + pathNode.GetGCost().ToString();
      hCostText.text = "H: " + pathNode.GetHCost().ToString();
      fCostText.text = "F: " + pathNode.GetFCost().ToString();
      isWalkableSprite.color = pathNode.IsWalkable() ? Color.green : Color.red;
   }

   public override void SetGridObject(object gridObject)
   {
      base.SetGridObject(gridObject);
      pathNode = (PathNode)gridObject;   }
}
