# Good tests

**Integration-style.** Test through real interfaces.

```typescript
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

**Verify through the interface.** After a write, read back through the public API.

```typescript
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

**Independent expected values.** A known literal, not a recomputation of the implementation.

```typescript
test("calculateTotal sums line items", () => {
  expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
});
```

## Red flags

- Mocking internal collaborators
- Testing private methods
- Asserting on call counts or order
- Verifying through a side channel instead of the interface
- Expected value recomputed the way the code computes it
- Test name describes how, not what
