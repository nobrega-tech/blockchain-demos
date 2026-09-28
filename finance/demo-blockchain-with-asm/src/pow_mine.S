/* x86-64 Windows Microsoft ABI
 * uint64_t mine_pow_asm(const uint8_t *prefix, uint32_t difficulty,
 *                       uint8_t out_hash[32], uint64_t *out_nonce);
 *
 * Prefix caching: sha256_update(prefix, 80) once, then per nonce
 * clone midstate -> update(nonce LE, 8) -> final. Matches Rust/Zig/C.
 */
    .intel_syntax noprefix
    .text
    .globl mine_pow_asm

/* SHA256_CTX is 112 bytes on this ABI. */
.set CTX_SIZE, 112

mine_pow_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push rsi
    push rdi
    push r12
    push r13
    push r14
    push r15
    /* Entry %16==8; 8 pushes -> still %16==8. Frame: align8 + 2*CTX + hash32 + nonce8 + slack */
    sub rsp, 280              /* 8 + 112 + 112 + 32 + 16 = 280 */

    mov r12, rcx              /* prefix */
    mov r13d, edx             /* difficulty */
    mov r14, r8               /* out_hash */
    mov r15, r9               /* out_nonce */

    /* prefix_ctx at [rsp+0], work_ctx at [rsp+112], hash at [rsp+224], nonce_le at [rsp+256] */

    /* sha256_init(&prefix_ctx) */
    mov rcx, rsp
    sub rsp, 32
    call sha256_init
    add rsp, 32

    /* sha256_update(&prefix_ctx, prefix, 80) */
    mov rcx, rsp
    mov rdx, r12
    mov r8d, 80
    sub rsp, 32
    call sha256_update
    add rsp, 32

    xor ebx, ebx              /* nonce = 0 */

.Lmine_loop:
    /* memcpy work_ctx = prefix_ctx (112 bytes) */
    cld
    lea rdi, [rsp + CTX_SIZE]
    mov rsi, rsp
    mov rcx, CTX_SIZE
    rep movsb

    /* nonce LE at [rsp+256] */
    mov qword ptr [rsp + 256], rbx

    /* sha256_update(&work_ctx, &nonce_le, 8) */
    lea rcx, [rsp + CTX_SIZE]
    lea rdx, [rsp + 256]
    mov r8d, 8
    sub rsp, 32
    call sha256_update
    add rsp, 32

    /* sha256_final(&work_ctx, hash) */
    lea rcx, [rsp + CTX_SIZE]
    lea rdx, [rsp + 224]
    sub rsp, 32
    call sha256_final
    add rsp, 32

    /* leading zero bits of hash at rsp+224 */
    lea rsi, [rsp + 224]
    xor eax, eax
    xor edx, edx
.Lbit_loop:
    cmp edx, 32
    jge .Lbit_done
    movzx ecx, byte ptr [rsi + rdx]
    test ecx, ecx
    jnz .Lbit_partial
    add eax, 8
    inc edx
    jmp .Lbit_loop
.Lbit_partial:
.Lbit_shift:
    test ecx, 0x80
    jnz .Lbit_done
    inc eax
    shl ecx, 1
    and ecx, 0xff
    jmp .Lbit_shift
.Lbit_done:
    cmp eax, r13d
    jae .Lmine_found

    inc rbx
    jmp .Lmine_loop

.Lmine_found:
    mov qword ptr [r15], rbx
    cld
    mov rdi, r14
    lea rsi, [rsp + 224]
    mov rcx, 32
    rep movsb

    mov rax, rbx
    inc rax

    add rsp, 280
    pop r15
    pop r14
    pop r13
    pop r12
    pop rdi
    pop rsi
    pop rbx
    pop rbp
    ret