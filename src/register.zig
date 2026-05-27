const std = @import("std");

pub const Access = enum { ro, wo, rw, rc_w0, rc_w1 };

pub const FieldSpec = struct {
    offset: u5,
    width: u6,
    access: Access = .rw,
};

pub fn Reg(comptime Fields: type) type {
    return extern struct {
        value: u32,

        const Self = @This();

        pub inline fn read(self: *volatile Self) u32 {
            return self.value;
        }

        pub inline fn write(self: *volatile Self, v: u32) void {
            self.value = v;
        }

        pub fn modify(self: *volatile Self, comptime fields: anytype) void {
            var val = self.value;
            inline for (@typeInfo(@TypeOf(fields)).@"struct".fields) |f| {
                const spec: FieldSpec = @field(Fields, f.name);
                comptime {
                    if (spec.access == .ro) @compileError("field '" ++ f.name ++ "' is read-only");
                }
                const mask: u32 = ((@as(u32, 1) << @as(u5, @intCast(spec.width))) - 1) << spec.offset;
                val = (val & ~mask) | ((@as(u32, @field(fields, f.name)) << spec.offset) & mask);
            }
            self.value = val;
        }

        // Computes the return type of get(): u32 for a single enum literal,
        // or a named struct { field: u32, ... } for a tuple of enum literals.
        fn GetType(comptime fields: anytype) type {
            if (@typeInfo(@TypeOf(fields)) == .enum_literal) return u32;
            const tuple = @typeInfo(@TypeOf(fields)).@"struct".fields;
            const n = tuple.len;
            var names: [n][:0]const u8 = undefined;
            var types: [n]type = undefined;
            for (tuple, 0..) |tf, i| {
                names[i] = @tagName(@field(fields, tf.name));
                types[i] = u32;
            }
            return @Struct(.auto, null, &names, &types, &@splat(.{}));
        }

        pub fn get(self: *volatile Self, comptime fields: anytype) GetType(fields) {
            const raw = self.value;
            if (@typeInfo(@TypeOf(fields)) == .enum_literal) {
                // Single field: .RXNE → u32
                const name = @tagName(fields);
                comptime if (!@hasDecl(Fields, name)) @compileError("no field '" ++ name ++ "' in register");
                const spec: FieldSpec = @field(Fields, name);
                comptime if (spec.access == .wo) @compileError("field '" ++ name ++ "' is write-only");
                return (raw >> spec.offset) & ((@as(u32, 1) << @as(u5, @intCast(spec.width))) - 1);
            } else {
                // Multiple fields: .{ .RXNE, .TXE } → struct { RXNE: u32, TXE: u32 }
                var result: GetType(fields) = undefined;
                inline for (@typeInfo(@TypeOf(fields)).@"struct".fields) |tf| {
                    const name = @tagName(@field(fields, tf.name));
                    comptime if (!@hasDecl(Fields, name)) @compileError("no field '" ++ name ++ "' in register");
                    const spec: FieldSpec = @field(Fields, name);
                    comptime if (spec.access == .wo) @compileError("field '" ++ name ++ "' is write-only");
                    @field(result, name) = (raw >> spec.offset) &
                        ((@as(u32, 1) << @as(u5, @intCast(spec.width))) - 1);
                }
                return result;
            }
        }
    };
}

test "write/read round-trip" {
    const Fields = struct {
        pub const X: FieldSpec = .{ .offset = 4, .width = 8 };
    };
    var r: Reg(Fields) = .{ .value = 0 };
    const p: *volatile Reg(Fields) = &r;
    p.write(0xABCD_1234);
    try std.testing.expectEqual(@as(u32, 0xABCD_1234), p.read());
}

test "get single field extracts correct bits" {
    const Fields = struct {
        pub const LO: FieldSpec = .{ .offset = 0, .width = 4, .access = .rw };
        pub const HI: FieldSpec = .{ .offset = 4, .width = 4, .access = .ro };
    };
    var r: Reg(Fields) = .{ .value = 0xAB };
    const p: *volatile Reg(Fields) = &r;
    try std.testing.expectEqual(@as(u32, 0xB), p.get(.LO));
    try std.testing.expectEqual(@as(u32, 0xA), p.get(.HI));
}

test "get multiple fields returns named struct" {
    const Fields = struct {
        pub const LO: FieldSpec = .{ .offset = 0, .width = 4, .access = .rw };
        pub const HI: FieldSpec = .{ .offset = 4, .width = 4, .access = .ro };
    };
    var r: Reg(Fields) = .{ .value = 0xAB };
    const p: *volatile Reg(Fields) = &r;
    const result = p.get(.{ .LO, .HI });
    try std.testing.expectEqual(@as(u32, 0xB), result.LO);
    try std.testing.expectEqual(@as(u32, 0xA), result.HI);
}

test "get on rc_w0 and rc_w1 fields is allowed" {
    const Fields = struct {
        pub const F0: FieldSpec = .{ .offset = 5, .width = 1, .access = .rc_w0 };
        pub const F1: FieldSpec = .{ .offset = 6, .width = 1, .access = .rc_w1 };
    };
    var r: Reg(Fields) = .{ .value = 0b11 << 5 };
    const p: *volatile Reg(Fields) = &r;
    try std.testing.expectEqual(@as(u32, 1), p.get(.F0));
    try std.testing.expectEqual(@as(u32, 1), p.get(.F1));
}

test "modify sets correct bits and preserves others" {
    const Fields = struct {
        pub const A: FieldSpec = .{ .offset = 0, .width = 4, .access = .rw };
        pub const B: FieldSpec = .{ .offset = 8, .width = 4, .access = .rw };
    };
    var r: Reg(Fields) = .{ .value = 0xFFFF_FFFF };
    const p: *volatile Reg(Fields) = &r;
    p.modify(.{ .A = 0x5, .B = 0x3 });
    try std.testing.expectEqual(@as(u32, 0xFFFF_F3F5), p.read());
}

test "modify masks value to field width" {
    const Fields = struct {
        pub const A: FieldSpec = .{ .offset = 4, .width = 4, .access = .rw };
    };
    // 0xFF passed but only 4 bits wide — must not bleed into neighbours
    var r: Reg(Fields) = .{ .value = 0 };
    const p: *volatile Reg(Fields) = &r;
    p.modify(.{ .A = 0xFF });
    try std.testing.expectEqual(@as(u32, 0xF0), p.read());
}

test "modify accumulates multiple fields in one pass" {
    const Fields = struct {
        pub const A: FieldSpec = .{ .offset = 0, .width = 1, .access = .rw };
        pub const B: FieldSpec = .{ .offset = 1, .width = 1, .access = .rw };
        pub const C: FieldSpec = .{ .offset = 2, .width = 1, .access = .rw };
    };
    var r: Reg(Fields) = .{ .value = 0 };
    const p: *volatile Reg(Fields) = &r;
    p.modify(.{ .A = 1, .B = 1, .C = 1 });
    try std.testing.expectEqual(@as(u32, 0b111), p.read());
}

// Compile-time access control — these lines must NOT compile:
//   p.modify(.{ .RO_FIELD = 1 })  →  error: field 'RO_FIELD' is read-only
//   p.get(.WO_FIELD)               →  error: field 'WO_FIELD' is write-only
//   p.get(.TYPO)                   →  error: no field 'TYPO' in register
