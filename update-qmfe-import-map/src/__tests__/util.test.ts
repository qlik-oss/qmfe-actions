import { normalizeBasePath, parseModulesInput, readVersionInput } from "../util";
import { describe, test, expect, jest } from "@jest/globals";

jest.mock("@actions/core");

describe("util", () => {
  describe("parseQmfeModules", () => {
    test("should return null if input is falsy", () => {
      expect(parseModulesInput(null)).toEqual(null);
    });

    test("should return list of strings when input is valid", () => {
      expect(parseModulesInput('["foo", "bar"]')).toEqual(["foo", "bar"]);
      expect(parseModulesInput("[]")).toEqual([]);
    });

    test("should throw if json string is invalid", () => {
      // Single quotes on properties is not valid
      expect(() => parseModulesInput("['foo', 'bar']")).toThrow();
      expect(() => parseModulesInput("foo")).toThrow();
    });
  });

  describe("normalizeBasePath", () => {
    test("should trim trailing slash", () => {
      expect(normalizeBasePath("https://cdn.com/")).toEqual("https://cdn.com");
      expect(normalizeBasePath("https://cdn.com")).toEqual("https://cdn.com");
    });
  });

  describe("readVersionInput", () => {
    test("should return correct version value", () => {
      expect(readVersionInput("v0.1.2")).toEqual("0.1.2");
      expect(readVersionInput("1.2.3")).toEqual("1.2.3");
    });
  });
});
