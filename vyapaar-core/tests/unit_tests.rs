use vyapaar_core::types::*;
use rust_decimal::Decimal;

#[test]
fn test_price_construction() {
    let p = Price(Decimal::new(10050, 2));
    assert_eq!(p.0.to_string(), "100.50");
}
