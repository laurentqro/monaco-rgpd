# Production Readiness Checklist

This document tracks critical security and infrastructure features that must be implemented before going to production.

## 🔴 Critical Security Features (MUST DO BEFORE PRODUCTION)

### 1. Secure Role Management Implementation

**Status**: ⚠️ PARKED FOR MVP - **MUST IMPLEMENT BEFORE PRODUCTION**

**Risk**: Currently, role changes use mass assignment which could allow privilege escalation attacks.

**Current State**:
- User roles can be changed via admin panel
- Role changes use standard mass assignment (`user.update(user_params)`)
- `:role` is included in permitted params in `Admin::UsersController`

**Security Issues**:
- Admins could potentially promote themselves to owner
- No protection against demoting the last owner (account lockout)
- No explicit authorization checks for role changes
- No audit trail for role changes

**Implementation Plan**:
- See `docs/plans/2025-10-26-secure-role-updates.md`
- TDD approach with 5 tasks
- Adds `RoleChangePolicy` for authorization
- Dedicated `update_role` controller action
- Frontend UI with permission checks
- Event publishing for audit trail

**Estimated Effort**: 4-6 hours

**Priority**: 🔴 **CRITICAL** - Must be done before production

**Test to Verify Fixed**: All tests in `test/policies/role_change_policy_test.rb` should pass

---

## 🟡 Important Pre-Production Tasks

### 2. Security Audit
- [ ] Run Brakeman security scan
- [ ] Review all mass assignment permissions
- [ ] Audit authentication flows
- [ ] Review CORS and session security

### 3. Infrastructure
- [ ] Set up production database backups
- [ ] Configure SSL/TLS certificates
- [ ] Set up monitoring and alerting
- [ ] Configure error tracking (e.g., Sentry)

### 4. Compliance
- [ ] GDPR compliance review
- [ ] Privacy policy
- [ ] Terms of service
- [ ] Cookie consent

### 5. Performance
- [ ] Database query optimization
- [ ] Asset caching strategy
- [ ] CDN configuration
- [ ] Load testing

---

## Review Schedule

This checklist should be reviewed:
- ✅ Before starting production deployment
- ✅ During security audits
- ✅ When adding new admin features

## Notes

**MVP Phase**: We're accepting the risk of insecure role management during MVP/beta with limited users. This is a **time-boxed decision** and must be addressed before general availability.

**Last Updated**: 2025-11-03
**Next Review**: Before production deployment
