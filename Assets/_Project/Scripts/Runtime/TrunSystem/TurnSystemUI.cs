using System;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TurnSystemUI : MonoBehaviour
{
   [SerializeField]
   private Button endTurnBtn;
   [SerializeField]
   private TextMeshProUGUI turnText;

   private void Start()
   {
      endTurnBtn.onClick.AddListener(() =>
      {
         TurnSystem.Instance.NextTurn();
      });

      TurnSystem.Instance.OnTurnChanged += TurnSystem_OnTurnChanged;

      UpdateTurnText();
   }

   private void TurnSystem_OnTurnChanged(object sender, EventArgs e)
   {
      UpdateTurnText();
   }

   private void UpdateTurnText()
   {
      turnText.text = $"Turn: {TurnSystem.Instance.GetTurnNumber()}";
   }
}
