using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class ActionButtonUI : MonoBehaviour
{
   [SerializeField]
   private TextMeshProUGUI actionName;
   [SerializeField]
   private Button button;
   [SerializeField]
   private GameObject selectedOverlay;

   private BaseAction baseAction;

   public void SetBaseAction(BaseAction baseAction)
   {
      this.baseAction = baseAction;
      actionName.text = baseAction.GetActionName();

      button.onClick.AddListener(() =>
      {
         UnitActionSystem.Instance.SetSelectedAction(baseAction);
      });
   }

   public void UpdateSelectedVisual()
   {
      BaseAction selectedAction = UnitActionSystem.Instance.GetSelectedAction();
      selectedOverlay.SetActive(selectedAction == baseAction);
   }
}
