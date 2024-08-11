using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ActionButtonUI : MonoBehaviour
{
   [SerializeField]
   private TextMeshProUGUI actionName;
   [SerializeField]
   private Button button;

   public void SetBaseAction(BaseAction baseAction)
   {
      actionName.text = baseAction.GetActionName();
   }
}
