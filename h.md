Sure, let's begin with the mathematical principles behind base conversions and then move on to the algorithmic side of it. A "base" or "radix" of a number system is the number of unique digits (including zero) used to represent numbers in that system.

## Mathematical Basis:

Any number $N$ in base $b$ can be represented as:

$$
N = d_0 b^0 + d_0 b^1 + d_2 b^2 + ... + d_n b^n
$$

where $0 \leq d_i < b$ for all $0 \leq i \leq n$. These $d_i$ are the digits of the number in base $b$.

The process of converting a number between bases is essentially about rearranging this equation.

### Base to Base10:

Let's consider you have a number in base $b$ and you want to convert it to base $10$. This is straightforward because our standard number system is base $10$.

If $N = d_0 \cdot b^0 + d_1 b^1 + d_2 b^2 + ... + d_n b^n$, then in base $10$, you directly compute this sum.

### Base10 to Another Base:

If you have a base $10$ number and you want to convert it to base $b$, you can use the division-remainder method:

1. Divide the number by $b$.
2. Record the remainder $r$.
3. Replace the number with the division result.
4. Repeat the steps until the number becomes $0$.
5. The digits of the number in base $b$ are the remainders in reverse order of computation.

## Algorithmic Implementation:

Let's use Python for this demonstration. Python's built-in arbitrary precision arithmetic makes it a good choice.

### Base to Base10:

```python
def to_base10(s, b):
    base10 = 0
    for i, digit in enumerate(reversed(s)):
        base10 += int(digit) * (b ** i)
    return base10
```

### Base10 to Another Base:

```python
def from_base10(n, b):
    digits = []
    while n > 0:
        n, r = divmod(n, b)
        digits.append(str(r))
    return ''.join(reversed(digits))
```

### Arbitrary Base to Another Base:

To convert from base $b1$ to base $b2$, you can first convert to base $10$, then to $b2$:

```python
def convert_bases(s, b1, b2):
    return from_base10(to_base10(s, b1), b2)
```

## Special Cases and Optimization:

If you're converting between two bases that are powers of each other (like base $2$ and base $16$), you can convert $m$ digits at a time, where $b_1^m = b_2$.

For your specific case (base$26$ to base$256$), there's no such quick conversion, because $256$ isn't a power of $26$. So you'll need to go through base $10$ (or do an equivalent calculation), and the size of the numbers will be limited by your language's integer or floating-point size.

Keep in mind that these Python functions deal with numbers, not ASCII strings. If you're starting with an ASCII string (like `abc`), you'll need to convert characters to/from numbers. This also means you'll need to decide what to do with non-alphanumeric characters and potentially validate the input. Also note that the `from_base10` function returns a string of digits, not an integer.

I hope this gives you a comprehensive understanding of base conversions. If you want to dive deeper into this topic, I'd recommend studying number theory or computer arithmetic.

## Direct Base Conversion

Absolutely. To convert directly between two arbitrary bases without going through base $10$, we can leverage the underlying mathematical principles and adapt the division-remainder algorithm to work directly in the source base.

Here is an abstract version of the process, which essentially performs "long division" in the source base. It uses a source base $b_1$, target base $b_2$, and a number in base $b_1$ represented as a string $s$ with $n$ digits $d[i]$.

1. Initialize a carry variable to 0 and an array to hold the result.

2. For each digit $d[i]$ in $s$, from left to right:
    1. Multiply the carry by $b_1$ and add the current digit $d[i]$.
    2. Divide this result by $b_2$ to get a quotient and remainder.
    3. The quotient becomes the new carry, and the remainder is added to the result array.

3. If there is any carry left after going through all the digits, convert it to base $b_2$ (using the division-remainder method in base $b_2$) and add it to the result array.

4. Reverse the result array to get the number in base $b_2$ in the correct order.

Note that the division and multiplication in steps 2.1 and 2.2, and the conversion in step 3 are all performed in base $b_1$. The only conversion to $b_2$ happens when adding to the result array.

This process works regardless of the values of $b_1$ and $b_2$ and does not require converting the whole number to base 10. However, it does involve converting individual digits and remainders, so it assumes that these are small enough to fit into an integer variable in your programming language. If the bases are very large, you may need to implement arbitrary-precision arithmetic operations for these steps.

Also, the input number $s$ is represented as a string where each character corresponds to a digit in base $b_1$. For bases larger than $10$, you will need a way to represent digits larger than $9$. This could be done using multiple characters for each digit, or by using a larger character set (such as uppercase and lowercase letters for bases up to $62$). Similarly, the result will be a string in base $b_2$, which may require encoding digits larger than $9$ if $b_2$ is larger than $10$.

Finally, this process assumes that $s$ is a valid number in base $b_1$. If it's possible for $s$ to contain invalid characters (for example, if it's user input), you should validate it before starting the conversion.