using System;
using UnityEngine;

public class UnitAnimator : MonoBehaviour
{
   private const string IS_WALKING = "IsWalking";
   private const string SHOOT = "Shoot";
   private const string SWORD_JUMP_ATTACK = "SwordJumpAttack";
   private const string MOVE_JUMP_UP = "JumpUp";
   private const string MOVE_DROP_DOWN = "JumpDown";

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
      if(TryGetComponent(out MoveAction moveAction))
      {
         moveAction.OnStartMoving += MoveAction_OnStartMoving;
         moveAction.OnStopMoving += MoveAction_OnStopMoving;
         moveAction.OnStartJumping += MoveAction_OnStartJumping;
      }
      if(TryGetComponent(out ShootAction shootAction))
      {
         shootAction.OnShoot += ShootAction_OnShoot;
      }
      if (TryGetComponent(out SwordAction swordAction))
      {
         swordAction.OnSwordActionStarted += SwordAction_OnSwordActionStarted;
         swordAction.OnSwordActionCompleted += SwordAction_OnSwordActionCompleted;
      }
   }

   private void Start()
   {
      EquipRifle();
   }

   private void MoveAction_OnStartJumping(object sender, MoveAction.OnStartJumpEventArgs e)
   {
      if (e.targetGridPosition.floor > e.unitGridPosition.floor)
      {
         animator.SetTrigger(MOVE_JUMP_UP);
      }
      else
      {
         animator.SetTrigger(MOVE_DROP_DOWN);
      }
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

      float unitShoulderHeight = 1.7f;

      shootAtPosition.y += unitShoulderHeight;
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
