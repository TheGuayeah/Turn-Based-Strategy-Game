using System;
using UnityEngine;

public class UnitAnimator : MonoBehaviour
{
   private const string IS_WALKING = "IsWalking";
   private const string SHOOT = "Shoot";
   private const string SWORD_JUMP_ATTACK = "SwordJumpAttack";

   [SerializeField]
   private Animator animator;
   [SerializeField]
   private Transform bulletPrefab;
   [SerializeField]
   private Transform shootPoint;
   [SerializeField]
   private Transform rifleTransform;
   [SerializeField]
   private Transform swordTransform;

   private void Awake()
   {
      if(TryGetComponent<MoveAction>(out MoveAction moveAction))
      {
         moveAction.OnStartMoving += MoveAction_OnStartMoving;
         moveAction.OnStopMoving += MoveAction_OnStopMoving;
      }
      if(TryGetComponent<ShootAction>(out ShootAction shootAction))
      {
         shootAction.OnShoot += ShootAction_OnShoot;
      }
      if (TryGetComponent<SwordAction>(out SwordAction swordAction))
      {
         swordAction.OnSwordActionStarted += SwordAction_OnSwordActionStarted;
         swordAction.OnSwordActionCompleted += SwordAction_OnSwordActionCompleted;
      }
   }

   private void Start()
   {
      EquipRifle();
   }

   private void MoveAction_OnStartMoving(object sender, EventArgs e)
   {
      animator.SetBool(IS_WALKING, true);
   }

   private void MoveAction_OnStopMoving(object sender, EventArgs e)
   {
      animator.SetBool(IS_WALKING, false);
   }

   private void ShootAction_OnShoot(object sender, ShootAction.OnShootEventArgs e)
   {
      animator.SetTrigger(SHOOT);

      Transform bulletTransform = 
         Instantiate(bulletPrefab, shootPoint.position, Quaternion.identity);
      BulletProjectile bulletProjectile = bulletTransform.GetComponent<BulletProjectile>();
      
      Vector3 shootAtPosition = e.targetUnit.GetWorldPosition();
      shootAtPosition.y = shootPoint.position.y;
      bulletProjectile.Setup(shootAtPosition);
   }

   private void SwordAction_OnSwordActionStarted(object sender, EventArgs e)
   {
      EquipSword();
      animator.SetTrigger(SWORD_JUMP_ATTACK);
   }

   private void SwordAction_OnSwordActionCompleted(object sender, EventArgs e)
   {
      EquipRifle();
   }

   private void EquipSword()
   {
      swordTransform.gameObject.SetActive(true);
      rifleTransform.gameObject.SetActive(false);
   }

   private void EquipRifle()
   {
      rifleTransform.gameObject.SetActive(true);
      swordTransform.gameObject.SetActive(false);
   }
}
